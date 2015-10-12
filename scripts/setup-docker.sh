#/bin/bash

# Add the Docker repo GPG key
if ! which docker > /dev/null; then
  echo "Docker not installed. Adding respository (requires sudo)"
  sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  sudo add-apt-repository 'deb https://apt.dockerproject.org/repo ubuntu-vivid main'

  echo "Installing Docker (requires sudo)"
  sudo apt-get -q update
  sudo apt-get -qfuy install docker-engine
fi

echo "Checking if ufw is running (may require sudo)"
if which ufw > /dev/null && sudo ufw status | grep -qw active; then
  FWD_POLICY_STRING="DEFAULT_FORWARD_POLICY=\"ACCEPT\""
  if ! grep -qw $FWD_POLICY_STRING; then
    echo "Setting $FWD_POLICY_STRING (requires sudo)"
    sudo sed -i.bak \
      's/DEFAULT_FORWARD_POLICY="[a-zA-Z]"/'.DEFAULT_FORWARD_POLICY.'/g' \
      /etc/default/ufw
    sudo rm /etc/default/ufw.bak
  fi

  echo "Allowing incoming connections on Docker port (requires sudo)"
  sudo ufw allow 2375/tcp
fi

echo "Docker installed and setup"
