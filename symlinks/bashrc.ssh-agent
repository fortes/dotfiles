#!/bin/bash
# Start / connect to SSH agent
SSH_AGENT_FILE="$HOME/.ssh/agent"
ssh-add -l &> /dev/null
if [ $? -eq 2 ]; then
  if [ -r "$SSH_AGENT_FILE" ]; then
    . "$SSH_AGENT_FILE" > /dev/null
  fi

  ssh-add -l &> /dev/null
  if [ $? -eq 2 ]; then
    echo "Starting a new agent"
    ssh-agent > "$SSH_AGENT_FILE"
    chmod 600 "$SSH_AGENT_FILE"
    . "$SSH_AGENT_FILE" > /dev/null
    ssh-add -l
  fi
fi
