import { Action, ActionPanel, Icon, LaunchProps, List, showHUD, showToast, Toast } from "@raycast/api";
import { useCachedPromise } from "@raycast/utils";
import { useState } from "react";
import { addAlbum, Album, errorMessage, searchAlbums } from "./mpd";

export default function PlayAlbums(props: LaunchProps<{ arguments: Arguments.PlayAlbums }>) {
  const [query, setQuery] = useState(props.arguments.query);
  // Half-typed queries fail, so errors show in the list rather than as toasts
  const { data, error, isLoading } = useCachedPromise(searchAlbums, [query], {
    keepPreviousData: true,
    onError: () => {},
  });

  return (
    <List
      isLoading={isLoading}
      filtering={false}
      throttle
      searchText={query}
      onSearchTextChange={setQuery}
      searchBarPlaceholder="Beets query, e.g. year:2025 genre:rock (default: added in the last 4 weeks)"
    >
      {error ? (
        <List.EmptyView icon={Icon.Warning} title={errorMessage(error)} />
      ) : (
        data?.map((album) => (
          <List.Item
            key={album.id}
            icon={Icon.Music}
            title={album.album}
            subtitle={album.artist}
            accessories={[{ text: album.genres }, { tag: album.year }]}
            actions={<AlbumActions album={album} />}
          />
        ))
      )}
    </List>
  );
}

function AlbumActions({ album }: { album: Album }) {
  // showHUD closes Raycast; the work happens first so it can't be cut off
  const add = async (replace: boolean) => {
    const toast = await showToast({ style: Toast.Style.Animated, title: replace ? "Playing…" : "Queueing…" });
    try {
      const count = await addAlbum(album.id, { replace });
      await showHUD(`${replace ? "Playing" : "Queued"} ${album.album} (${count} songs)`);
    } catch (error) {
      toast.style = Toast.Style.Failure;
      toast.title = "Couldn't add album";
      toast.message = errorMessage(error);
    }
  };

  return (
    <ActionPanel>
      <Action title="Play" icon={Icon.Play} onAction={() => add(true)} />
      {/* Raycast gives the second action ⌘↵ */}
      <Action title="Add to Queue" icon={Icon.Plus} onAction={() => add(false)} />
    </ActionPanel>
  );
}
