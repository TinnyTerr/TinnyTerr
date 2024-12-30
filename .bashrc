#!/bin/bash

alias myip="ifconfig | sed -En 's/.*inet (addr:)?(192\.168\.[0-9]+\.[0-9]+).*/\2/p'"

# Check if oh-my-posh is installed in the correct place. If not, use a preset PS1
test -d $HOME/.cache/oh-my-posh/
returned=$?
if [ $returned -ne 0 ]; then
  export PROMPT_COMMAND='PS1_CMD1=$(tty); PS1_CMD2=$(myip)'; 
  export PS1='\[\e[90m\][\!]\[\e[0m\] \[\e[36m\]\T\[\e[0m\] \[\e[36m\]\d\[\e[0m\] \[\e[90m\][\[\e[38;5;32m\]\u@\H\[\e[90m\]:\[\e[0m\]${PS1_CMD1} \[\e[38;5;47m\]${PS1_CMD2}\[\e[90m\]]\[\e[0m\] \w\n\$ '
else 
  eval "$(oh-my-posh init bash --config $HOME/.cache/oh-my-posh/themes/atomic.omp.json)"
fi

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Now motd

which figlet > /dev/null
returned=$?
if [ $returned -eq 0 ]; then
  hostname=$(hostname)
  title=$(figlet -f standard $hostname)
fi

# CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

# Memory usage
memory_usage=$(free -m | awk '/^Mem/{printf("%.2f%%", $3/$2*100.0)}')

# External IP
external_ip=$(curl -s https://api.ipify.org)

# External IP
user=$(whoami)

# Colouring
RED="\e[31m"
CYAN="\e[36m"
NC="\e[0m" # No Color

# Message
printf "${RED}"
echo -e "${title}"
echo -e "${CYAN}-----------------------------------------------------------${NC}"
echo -e "${CYAN} CPU usage:${NC} $cpu_usage"
echo -e "${CYAN} Memory usage:${NC} $memory_usage"
echo -e "${CYAN} External IP:${NC} $external_ip"
echo -e "${CYAN} System Boot:${NC} $(uptime -s) ($(uptime -p))"
echo -e "${CYAN} Users logged in:${NC} $(who | wc -l)"
echo -e "${CYAN} Welcome${NC} $user${CYAN}! "
echo -e "${CYAN}-----------------------------------------------------------${NC}"
