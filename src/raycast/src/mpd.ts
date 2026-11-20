import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { promisify } from "node:util";

// Raycast doesn't run a login shell, so it misses Homebrew's PATH and the
// BEETSDIR that ~/.profile sets for the MPD setup
export const env = {
  ...process.env,
  PATH: `/opt/homebrew/bin:/usr/local/bin:${process.env.PATH}`,
  BEETSDIR: process.env.BEETSDIR ?? `${homedir()}/.mpd/beets`,
};

const execFileAsync = promisify(execFile);

export async function run(command: string, args: string[], input?: string): Promise<string> {
  const child = execFileAsync(command, args, { env, maxBuffer: 64 * 1024 * 1024 });
  if (input !== undefined) {
    child.child.stdin?.end(input);
  }
  return (await child).stdout;
}

// The last line a failed command printed, rather than "Command failed: …".
// beets prints unrelated OMP warnings before its errors
export function errorMessage(error: unknown): string {
  return (
    (error as { stderr?: string }).stderr?.trim().split("\n").pop() ||
    (error instanceof Error ? error.message : String(error))
  );
}

// Where beets keeps its music, with `-d` filling in the default
let musicDir: Promise<string> | undefined;
function getMusicDir() {
  musicDir ??= run("beet", ["config", "-d"]).then((config) =>
    (config.match(/^directory: (.*)$/m)?.[1] ?? "").replace(/^~/, homedir()).replace(/\/$/, ""),
  );
  return musicDir;
}

export type Album = { id: string; year: string; artist: string; album: string; genres: string };

const ALBUM_FORMAT = "$id\t$original_year\t$albumartist\t$album\t$genres";

// Same sort and default query as play-albums
export async function searchAlbums(query: string): Promise<Album[]> {
  // Any beet command creates a missing library, and mpd-sync then sees the
  // empty one as current. mpd-sync downloads it to $BEETSDIR/library.db
  if (!existsSync(`${env.BEETSDIR}/library.db`)) {
    throw new Error("No beets library; run mpd-sync");
  }
  // Split on spaces outside double quotes, so artist:"beth gibbons" stays one
  // term. Single quotes stay literal, since album names are full of them
  const terms = query.match(/(?:[^\s"]+|"[^"]*")+/g)?.map((term) => term.replaceAll('"', "")) ?? ["added:-4w.."];
  const out = await run("beet", [
    "ls",
    "--album",
    `--format=${ALBUM_FORMAT}`,
    "added-",
    "albumartist+",
    "original_year-",
    ...terms,
  ]);
  return out
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const [id, year, artist, album, genres] = line.split("\t");
      return { id, year, artist, album, genres };
    });
}

// MPD names songs relative to its music directory, which is beets' directory
export async function addAlbum(id: string, { replace }: { replace: boolean }) {
  const prefix = `${await getMusicDir()}/`;
  const paths = (await run("beet", ["ls", "--path", "disc+", "track+", `album_id:${id}`]))
    .split("\n")
    .filter(Boolean)
    .map((path) => (path.startsWith(prefix) ? path.slice(prefix.length) : path));
  // An empty list would make `mpc add` queue the whole library
  if (paths.length === 0) {
    throw new Error("No songs found");
  }
  if (replace) {
    await run("mpc", ["-q", "clear"]);
  }
  await run("mpc", ["-q", "add"], paths.join("\n") + "\n");
  if (replace) {
    await run("mpc", ["-q", "play", "1"]);
  }
  return paths.length;
}
