# Not interactive, end early.
[[ $- == *i* ]] || return

########################################
# Theme
########################################
# Change this to switch oh-my-posh themes.
OMP_THEME="catppuccin_macchiato.omp.json"

########################################
# Bash Options
########################################
shopt -s cdspell dirspell   # Correct minor cd/dir typos
shopt -s histappend         # Append to history, don't overwrite

########################################
# History Configuration
########################################
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups

########################################
# Key Bindings
########################################
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\C-W": backward-delete-word'

########################################
# Path Additions
########################################

# Lazy load NVM — only initialises when you first call nvm/node/npm/npx
export NVM_DIR="$HOME/.nvm"
_nvm_lazy() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ]          && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  "$@"
}
nvm() { _nvm_lazy nvm  "$@"; }
node() { _nvm_lazy node "$@"; }
npm()  { _nvm_lazy npm  "$@"; }
npx()  { _nvm_lazy npx  "$@"; }

[ -f "$HOME/.deno/env" ]    && . "$HOME/.deno/env"
[ -s "$HOME/.bun/_bun" ]    && source "$HOME/.bun/_bun"

command -v zoxide >/dev/null && eval "$(zoxide init bash)"
command -v fzf    >/dev/null && eval "$(fzf --bash)"

for dir in "$HOME"/.local/*/bin; do
  [ -d "$dir" ] && export PATH="$dir:$PATH"
done

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

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
alias ga='git add'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gs='git status -sb'
alias gco='git checkout'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gst='git stash'
alias gstp='git stash pop'

alias br='bun run'
alias bi='bun install'
alias bx='bunx'

alias here='${EDITOR:-code} .'

# eza instead of ls (if available)
if command -v eza >/dev/null; then
  alias la="eza -Als type --git -T --hyperlink --header -L 2 -I node_modules"
  alias ls="eza -Als type --group-directories-first --icons"
fi

########################################
# Functions
########################################

externalip() {
  local tmpdir="$HOME/.local/share/temp/extip"
  local interfaces ip iface

  # Fixed: was checking if dir exists to create it; should be the opposite
  if [ ! -d "$tmpdir" ]; then
    mkdir -p "$tmpdir"
  fi

  interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)

  set +m
  for iface in $interfaces; do
    {
      ip=$(curl --silent --max-time 5 --interface "$iface" icanhazip.com 2>/dev/null || echo "Failed")
      echo "$ip" > "$tmpdir/$iface.out"
    } &
  done
  wait
  set -m

  grep -v "Failed" "$tmpdir"/*.out | sort
}

localip() {
  ip addr show |
    awk '/inet / && $2 !~ /^127\./ {print $2}' |
    cut -d/ -f1 |
    grep -E '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)' ||
  ip addr show |
    awk '/inet / && $2 !~ /^127\./ {print $2}' |
    cut -d/ -f1
}

mkcd()    { mkdir -p "$1" && cd "$1" || return; }
calc()    { [ "$1" ] && echo "scale=6; $*" | bc -l || echo "Usage: calc <expr>"; }
histg()   { history | grep --color=auto -i "$*"; }
wiki()    { [ "$1" ] && ${BROWSER:-w3m} "https://wiki.archlinux.org/?search=$*" || echo "Usage: wiki <term>"; }
wtfis()   { curl "https://cheat.sh/$*"; }
serve()   { local p=${1:-8000}; echo "Serving on http://localhost:$p"; python3 -m http.server "$p"; }

extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file>"
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.rar)     unrar x  "$1" ;;
    *.gz)      gunzip   "$1" ;;
    *.tar)     tar xf   "$1" ;;
    *.tbz2)    tar xjf  "$1" ;;
    *.tgz)     tar xzf  "$1" ;;
    *.zip)     unzip    "$1" ;;
    *.xz)      unxz     "$1" ;;
    *.7z)      7z x     "$1" ;;
    *) echo "extract: '$1' - unknown archive"; return 1 ;;
  esac
}

gqp() {
  git add -A
  git commit -m "${1:-WIP: $(date '+%Y-%m-%d %H:%M')}"
  git push
}

########################################
# Git Completion (if available)
########################################
if [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
fi

__git_complete gco  _git_checkout
__git_complete gc   _git_commit
__git_complete gp   _git_push
__git_complete gpl  _git_pull
__git_complete gb   _git_branch

########################################
# Prompt
########################################
OMP_CONFIG="$HOME/.cache/oh-my-posh/themes/$OMP_THEME"

if command -v oh-my-posh >/dev/null && [ -f "$OMP_CONFIG" ]; then
  eval "$(oh-my-posh init bash --config "$OMP_CONFIG")"
else
  # Fallback prompt — resolves IP once per session, not every render
  if [ -z "$_CACHED_IP" ]; then
    export _CACHED_IP
    _CACHED_IP=$(localip 2>/dev/null || echo "no-ip")
  fi

  _update_prompt() {
    local tty; tty=$(tty)
    history -a; history -n
    PS1="\[\e[90m\][\!]\[\e[0m\] \[\e[36m\]\T\[\e[0m\] \[\e[90m\][\[\e[1;38;5;75m\]\u@\H\[\e[0m\]\[\e[90m\]:${tty} \[\e[38;5;83m\]${_CACHED_IP}\[\e[90m\]]\[\e[0m\] \[\e[1m\]\w\[\e[0m\]\n\$ "
  }

  PROMPT_COMMAND='_update_prompt'
fi

########################################
# Message of the Day (MOTD)
########################################
clear
command -v fastfetch >/dev/null && fastfetch --config "$LOCAL_REPO/fastfetch.jsonc"
