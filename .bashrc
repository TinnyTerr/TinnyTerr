#!/usr/bin/env

########################################
# Bash Options
########################################
shopt -s cdspell dirspell           # Correct minor cd/dir typos
shopt -s histappend                 # Append to history, don't overwrite

########################################
# History Configuration
########################################
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export PROMPT_COMMAND='history -a; history -n;'"$PROMPT_COMMAND"

########################################
# Key Bindings
########################################
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\C-W": backward-delete-word'

########################################
# Path additions
########################################

# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Local
export PATH="$HOME/.local/bin:"$PATH
########################################
# Aliases
########################################
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -pv'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias reload='source ~/.bashrc'
alias df='df -h'
alias du='du -sh'
alias g='git'
alias gs='git status -sb'
alias gco='git checkout'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'

# eza instead of ls (if available)
if command -v eza >/dev/null; then
    alias la="eza -Als type --git -T --hyperlink --header -L 2 -I node_modules"
    alias ls="eza -Als type -I '.*'"
fi

########################################
# Functions
########################################
myip() {
    ip addr show |
    awk '/inet / && $2 !~ /^127\./ {print $2}' |
    cut -d/ -f1 |
    grep -E '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' ||
    ip addr show |
    awk '/inet / && $2 !~ /^127\./ {print $2}' |
    cut -d/ -f1
}
mkcd() { mkdir -p "$1" && cd "$1" || return; }
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <file>"
        return 1
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.rar)     unrar x "$1" ;;
        *.gz)      gunzip "$1" ;;
        *.tar)     tar xf "$1" ;;
        *.tbz2)    tar xjf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.zip)     unzip "$1" ;;
        *.xz)      unxz "$1" ;;
        *.7z)      7z x "$1" ;;
        *)         echo "extract: '$1' - unknown archive"; return 1;;
    esac
}
calc() { [ "$1" ] && echo "scale=6; $*" | bc -l || echo "Usage: calc <expr>"; }
histg() { history | grep --color=auto -i "$*"; }
wiki() { [ "$1" ] && lynx "https://wiki.archlinux.org/index.php?search=$*" || echo "Usage: wiki <term>"; }
wtfis() { curl "https://cheat.sh/$*"; }
serve() { local p=${1:-8000}; echo "📡 Serving on http://localhost:$p"; python3 -m http.server "$p"; }
gqp() {
    git add .
    git commit -m "${1:-Quick commit}"
    git push
}

########################################
# Git Completion (if available)
########################################
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi
__git_complete gco _git_checkout
__git_complete gc _git_commit
__git_complete gp _git_push
__git_complete gpl _git_pull
__git_complete gb _git_branch

########################################
# Prompt
########################################
if [ -d "$HOME/.cache/oh-my-posh/" ]; then
    eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/catppuccin_mocha.omp.json")"
else
    export PROMPT_COMMAND='PS1_CMD1=$(tty); PS1_CMD2=$(myip)'
    export PS1='\[\e[90m\][\!]\[\e[0m\] \[\e[36m\]\T\[\e[0m\] \[\e[36m\]\d\[\e[0m\] \[\e[90m\][\[\e[38;5;32m\]\u@\H\[\e[90m\]:\[\e[0m\]${PS1_CMD1} \[\e[38;5;47m\]${PS1_CMD2}\[\e[90m\]]\[\e[0m\] \w\n\$ '
fi

########################################
# Message of the Day (MOTD)
########################################
if command -v hostname >/dev/null; then
    host_name=$(hostname)
else
    host_name=$(cat /etc/hostname)
fi

if command -v figlet >/dev/null && figlet -f standard "$host_name" >/dev/null 2>&1; then
    title=$(figlet -f standard "$host_name")
else
    title="*** $host_name ***"
fi

clear
echo -e "\e[1;36m$title\e[0m"
echo -e "\e[33mUptime:\e[0m $(uptime -p)"
echo -e "\e[33mMemory:\e[0m $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo -e "\e[33mLocal IP(s):\n\e[0m$(myip)"
echo
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
