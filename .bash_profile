# Not interactive, end early.
[[ $- == *i* ]] || return

export LOCAL_REPO="$HOME/.local/share/bashrc_repo"
REMOTE_REPO="https://github.com/TinnyTerr/TinnyTerr.git"
BRANCH="main"
FILE_TO_SOURCE=".bashrc"

# ── Sync repo (all git ops in a subshell so $PWD is never changed) ──────────
(
  # Clone if missing
  if [ ! -d "$LOCAL_REPO" ]; then
    git clone -q -b "$BRANCH" "$REMOTE_REPO" "$LOCAL_REPO"
  fi

  cd "$LOCAL_REPO" || exit

  # Rate-limit fetches: skip if we fetched within the last 60 seconds
  LOCK="$LOCAL_REPO/.last_fetch"
  NOW=$(date +%s)
  LAST=0
  [ -f "$LOCK" ] && LAST=$(cat "$LOCK")

  if (( NOW - LAST > 60 )); then
    echo "$NOW" > "$LOCK"
    git fetch origin "$BRANCH" -q 2>/dev/null

    LOCAL_HASH=$(git rev-parse "$BRANCH" 2>/dev/null)
    REMOTE_HASH=$(git rev-parse "origin/$BRANCH" 2>/dev/null)

    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
      echo "Updating bashrc from remote..."
      git reset --hard "origin/$BRANCH" -q 2>/dev/null
    fi
  fi
) &   # ← runs in background; your shell's CWD is never touched

# Wait only for the clone step to finish (needed before sourcing)
# If the repo already existed this wait is near-instant.
wait

[ -f "$LOCAL_REPO/$FILE_TO_SOURCE" ] && source "$LOCAL_REPO/$FILE_TO_SOURCE"

# ── Restore last directory (optional prompt) ─────────────────────────────────
if [ -f ~/.lastdir ]; then
  lastdir="$(cat ~/.lastdir)"
  if [ -d "$lastdir" ] && [ "$lastdir" != "$HOME" ]; then
    read -rp "Restore last directory ($lastdir)? [y/N] " answer
    case "$answer" in
      [yY]*) cd "$lastdir" || true ;;
    esac
  fi
fi

# Save working directory on exit (trap set after cd logic)
trap 'pwd > ~/.lastdir' EXIT
