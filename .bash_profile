# Not interactive, end early.
[[ $- == *i* ]] || return

LOCAL_REPO="$HOME/.local/share/bashrc_repo"
REMOTE_REPO="https://github.com/TinnyTerr/TinnyTerr.git"
BRANCH="main"
FILE_TO_SOURCE="bashrc_snippet"

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
    # Only source after update
    [ -f "$LOCAL_REPO/$FILE_TO_SOURCE" ] && source "$LOCAL_REPO/$FILE_TO_SOURCE"
fi
