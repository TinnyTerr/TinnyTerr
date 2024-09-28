#!/bin/bash

export PROMPT_COMMAND='PS1_CMD1=$(tty)'; 
export PS1='\[\e[90m\][\!]\[\e[0m\] \[\e[36m\]\T\[\e[0m\] \[\e[36m\]\d\[\e[0m\] \[\e[90m\][\[\e[38;5;32m\]\u@\H\[\e[90m\]:\[\e[0m\]${PS1_CMD1}\[\e[90m\]]\[\e[0m\] \w\n\$ '

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
