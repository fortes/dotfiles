# syntax=docker/dockerfile:1
# Two targets: the default (last) stage is the dev container image, and `host`
# (`--target host`) is a fresh Debian server running script/setup, so CI
# catches host setup breakage.
ARG USER_NAME=fortes \
    USER_ID=1000 \
    GROUP_ID=1000 \
    TZ=America/New_York

# What a fresh server has before setup: a user with sudo, and git and curl to
# fetch the repo
FROM debian:trixie AS base
ARG USER_NAME USER_ID GROUP_ID TZ DEBIAN_FRONTEND=noninteractive
ENV TZ=$TZ
RUN apt-get -qq update && \
  apt-get install -qq --no-install-recommends -y ca-certificates curl git sudo && \
  rm -rf /var/lib/apt/lists/* && \
  echo "ALL ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/10-nopasswd && \
  groupadd --gid $GROUP_ID $USER_NAME && \
  useradd --uid $USER_ID --gid $GROUP_ID --groups sudo \
    --home-dir /home/$USER_NAME --create-home --shell /bin/bash $USER_NAME
USER $USER_NAME
WORKDIR /home/$USER_NAME

# The optional GH_TOKEN secret, here and below, lifts install_github_packages
# past the 60/hour unauthenticated API limit without baking the token into a
# layer. Read as a file, since Debian's podman predates `env=` secret mounts:
#   podman build --secret id=GH_TOKEN,env=GH_TOKEN -t dotfiles .
FROM base AS host
ARG USER_NAME
COPY --chown=$USER_NAME:$USER_NAME . dotfiles/
RUN --mount=type=secret,id=GH_TOKEN,mode=0444 \
  export GH_TOKEN="$(cat /run/secrets/GH_TOKEN 2>/dev/null)" && \
  ./dotfiles/script/setup
CMD ["bash", "--login"]

FROM base AS dev
ARG USER_NAME DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# The host apt list minus `# host-only` lines, with backports enabled as
# setup_linux does on hosts. This layer only rebuilds when
# the list changes, which keeps apt downloads cached.
COPY script/apt-packages.txt /tmp/apt-packages.txt
USER root
RUN set -eux; \
  codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"; \
  printf '%s\n' \
    'Types: deb' \
    'URIs: http://deb.debian.org/debian' \
    "Suites: ${codename}-backports" \
    'Components: main' \
    'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
    >/etc/apt/sources.list.d/backports.sources; \
  apt-get -qq update; \
  awk 'NF && $1 !~ /^#/ && !/# host-only/ {print $1}' /tmp/apt-packages.txt \
    | xargs -r apt-get install -qq --no-install-recommends -y; \
  rm -rf /var/lib/apt/lists/* /tmp/apt-packages.txt; \
  sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Codex requires CODEX_HOME to exist. Pushes go through gh (a `gh auth login`
# saved in /state/gh, or the container's GH_TOKEN), so containers never need
# SSH keys.
RUN mkdir -p /workspaces /state/claude /state/codex /state/antigravity /state/gemini /state/gh && \
  chown -R $USER_NAME:$USER_NAME /workspaces /state && \
  git config --system credential.https://github.com.helper '!gh auth git-credential'
USER $USER_NAME

# agy has no setting for its directories, so link them into /state
RUN ln -s /state/antigravity .antigravity && ln -s /state/gemini .gemini

# ~/.local/bin (node, npm globals, etc.) for shells that skip ~/.profile, like
# `podman exec dotfiles node`. DOTFILES_DEV_IMAGE makes script/update add the
# coding toolchain. Corepack's prompt is off for agents that skip .profile too.
ENV IS_DOCKER=1 \
    DOTFILES_DEV_IMAGE=1 \
    PATH=/home/$USER_NAME/.local/bin:$PATH \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0

# Only the scripts, so dotfile edits don't rebuild this heavy layer; npm
# installs pass their release-age cooldown explicitly. Download caches (over a
# gigabyte), and the Claude Code and Codex config their installers and
# completions write, are deleted in the same layer, so no image carries one
# install's IDs.
COPY --chown=$USER_NAME:$USER_NAME script/ dotfiles/script/
RUN --mount=type=secret,id=GH_TOKEN,mode=0444 \
  export GH_TOKEN="$(cat /run/secrets/GH_TOKEN 2>/dev/null)" && \
  ./dotfiles/script/update && \
  sudo apt-get clean && \
  sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  rm -rf ~/.cache ~/.local/install/cache ~/.claude ~/.claude.json ~/.codex

# Agent and GitHub logins go in the /state mount, set only after installing
ENV CLAUDE_CONFIG_DIR=/state/claude \
    CODEX_HOME=/state/codex \
    GH_CONFIG_DIR=/state/gh

COPY --chown=$USER_NAME:$USER_NAME . dotfiles/
RUN ./dotfiles/script/stow

CMD ["/bin/bash"]
