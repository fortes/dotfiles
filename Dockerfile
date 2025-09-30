# Modify these to suit your needs
FROM debian:trixie

ARG USER_NAME=fortes \
    USER_ID=1000 \
    GROUP_ID=1000 \
    TZ=America/New_York \
    DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8 \
  TZ=$TZ

# Share the apt manifest with setup_linux so this layer only rebuilds when the package
# list changes. That keeps apt downloads cached between Docker builds.
COPY script/apt-packages.txt /tmp/apt-packages.txt

# Enable contrib/non-free and backports before installing packages so that
# every environment (Docker or host) sees the same repositories. Install all
# base packages in a single layer, then purge apt caches so we don't carry
# ~100 MB of metadata into later layers.
RUN set -eux; \
  codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"; \
  if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
    sed -i 's/Components: main$/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources; \
  else \
    sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list; \
  fi; \
  printf '%s\n' \
    'Types: deb' \
    'URIs: http://ftp.debian.org/debian' \
    "Suites: ${codename}-backports" \
    'Components: main contrib non-free non-free-firmware' \
    'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
    > /etc/apt/sources.list.d/backports.sources; \
  apt-get -qqy update; \
  awk 'NF && $1 !~ /^#/' /tmp/apt-packages.txt | xargs -r apt-get install -qq --no-install-recommends -y; \
  rm -rf /var/lib/apt/lists/* /tmp/apt-packages.txt

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Don't require password for `sudo` use
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10-docker-nopasswd

RUN groupadd --gid $GROUP_ID $USER_NAME && \
  useradd --uid $USER_ID --gid $GROUP_ID \
  --home-dir /home/$USER_NAME --create-home \
  --shell /bin/bash $USER_NAME && \
  usermod -aG sudo $USER_NAME

USER $USER_NAME
WORKDIR /home/$USER_NAME

# Create /workspaces directory for projects and Claude config
RUN sudo mkdir -p /workspaces && sudo chown $USER_NAME:$USER_NAME /workspaces

COPY --chown=$USER_NAME:$USER_NAME . /home/$USER_NAME/dotfiles

ENV IS_DOCKER=1 \
    SKIP_INITIAL_APT_INSTALL=1 \
    CLAUDE_CONFIG_DIR=/workspaces/.claude-container

RUN ./dotfiles/script/setup

# Free up disk space
RUN sudo apt-get clean && \
  sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]
