# Docker → Podman migration

One-time steps for each existing machine. Delete this file once every machine is migrated.

## Debian

```sh
# Installs rootless podman
./script/setup

# Only if this machine runs the long-running container
sudo loginctl enable-linger "$USER"
```

Log out and back in so the user D-Bus session takes effect. Check that `podman info` shows `rootless: true`.

Podman runs alongside Docker. `script/install_docker` reinstalls Docker on a rebuilt machine, without adding you to the docker group.

Leave the docker group once nothing runs Docker as your user without `sudo`:

```sh
sudo gpasswd -d "$USER" docker
```

The docker group is root-equivalent, but cron jobs, user units and scripts that call `docker` as you break without it (`sudo` resets `HOME` to `/root`). Stay in it until those move to podman or `sudo`.

Once nothing on the machine needs Docker, remove it:

```sh
sudo apt purge docker.io docker-buildx docker-clean docker-cli docker-compose
sudo apt autoremove --purge
sudo rm -rf /var/lib/docker /var/lib/containerd
```

## macOS

Colima and Docker stay installed as a fallback for projects that need them, but shouldn't start on login.

```sh
brew services stop colima

# Installs podman via brew
./script/setup

podman machine init --now
```

## Old containers and images

Docker containers, images and volumes don't carry over. Recreate containers with the README's commands.

## Checklist

- [ ] Mac
- [x] macaronesia
- [ ] (add each Debian server here)
