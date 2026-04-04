# Not interactive, end early.
[[ $- == *i* ]] || return

LOCAL_REPO="$HOME/.local/share/bashrc_repo"
REMOTE_REPO="https://github.com/TinnyTerr/TinnyTerr.git"
BRANCH="main"
FILE_TO_SOURCE=".bashrc"

dir=$(pwd)

# Save last directory on exit
trap 'pwd > ~/.lastdir' EXIT

# Clone repo if it doesn't exist
if [ ! -d "$LOCAL_REPO" ]; then
    git clone -b "$BRANCH" "$REMOTE_REPO" "$LOCAL_REPO"
fi



cd "$LOCAL_REPO" || return

# Check for remote updates without changing local files
git fetch origin "$BRANCH" >/dev/null 2>&1
LOCAL_HASH=$(git rev-parse "$BRANCH")
REMOTE_HASH=$(git rev-parse "origin/$BRANCH")

if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo "Updating bashrc snippet from remote..."
    git reset --hard "origin/$BRANCH" >/dev/null 2>&1
fi

[ -f "$LOCAL_REPO/$FILE_TO_SOURCE" ] && source "$LOCAL_REPO/$FILE_TO_SOURCE"

cd $dir

# On startup, prompt user
if [ -f ~/.lastdir ]; then
  lastdir="$(cat ~/.lastdir)"
  if [ -d "$lastdir" ] && [ "$lastdir" != "$HOME" ]; then
    read -p "Restore last directory ($lastdir)? [y/N] " answer
    case "$answer" in
      [yY]* ) cd "$lastdir" ;;
    esac
  fi
fi

