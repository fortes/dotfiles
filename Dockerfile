# Modify these to suit your needs
FROM debian:bullseye

ARG USER_NAME=fortes \
    USER_ID=1000 \
    GROUP_ID=1000 \
    TZ=America/New_York \
    DEBIAN_VERSION=bullseye \
    DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8 \
  TZ=$TZ

RUN apt-get -qqy update && \
  apt-get install -qq --no-install-recommends -y \
  ca-certificates sudo git locales lsb-release software-properties-common && \
  rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# Don't require password for `sudo` use
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10-docker-nopasswd

RUN addgroup --gid $GROUP_ID $USER_NAME && \
  adduser --disabled-password --gecos '' \
  --uid $USER_ID --gid $GROUP_ID $USER_NAME && \
  adduser $USER_NAME sudo

USER $USER_NAME
WORKDIR /home/$USER_NAME

RUN git clone https://github.com/fortes/dotfiles.git \
  --branch debian-$DEBIAN_VERSION && \
  ./dotfiles/scripts/setup_machine

SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]
