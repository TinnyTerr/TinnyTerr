#!/bin/bash

alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"

export PROMPT_COMMAND='PS1_CMD1=$(tty); PS1_CMD2=$(myip)'; 
export PS1='\[\e[90m\][\!]\[\e[0m\] \[\e[36m\]\T\[\e[0m\] \[\e[36m\]\d\[\e[0m\] \[\e[90m\][\[\e[38;5;32m\]\u@\H\[\e[90m\]:\[\e[0m\]${PS1_CMD1} \[\e[38;5;47m\]${PS1_CMD2}\[\e[90m\]]\[\e[0m\] \w\n\$ '

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Create a named pipe for inter-terminal communication (if not already created)
PIPE_FILE="/tmp/terminal_msg_pipe"
if [[ ! -p "$PIPE_FILE" ]]; then
  mkfifo "$PIPE_FILE"
fi

# Function to send a message to other terminals
send_msg() {
  if [ -z "$1" ]; then
    echo "Usage: send_msg <message>"
  else
    echo "$1" > "$PIPE_FILE"
  fi
}

# Function to listen for messages from other terminals
listen_msg() {
  while true; do
    if read msg <"$PIPE_FILE"; then
      echo -e "\n\033[1;32m[Message received]:\033[0m $msg\n$PS1"
    fi
  done
}

# Start listening for messages in the background when terminal starts
listen_msg &
