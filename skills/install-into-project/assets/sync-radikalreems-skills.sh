#!/usr/bin/env bash
# Sync radikalreems/skills into .cursor/skills/radikalreems.
# workspaceOpen hook: logs on stderr, "{}" on stdout.
set -euo pipefail

REPO_URL="https://github.com/radikalreems/skills.git"
REF="${RADIKALREEMS_SKILLS_REF:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST_DIR="$PROJECT_ROOT/.cursor/skills/radikalreems"
SRC_DIR="$DEST_DIR/.src"

log() {
  printf 'sync-radikalreems-skills: %s\n' "$*" >&2
}

emit() {
  printf '{}\n'
}

fail() {
  log "$1"
  emit
  exit 1
}

publish_skills() {
  local src="$SRC_DIR/skills"
  local name dest_skill src_skill

  if [ ! -d "$src" ]; then
    fail "clone has no skills/ directory"
  fi

  mkdir -p "$DEST_DIR"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude '.src' "$src/" "$DEST_DIR/" >&2
    return
  fi

  for dest_skill in "$DEST_DIR"/*/; do
    [ -d "$dest_skill" ] || continue
    name="$(basename "$dest_skill")"
    [ "$name" = ".src" ] && continue
    if [ ! -d "$src/$name" ]; then
      rm -rf "$dest_skill"
    fi
  done

  for src_skill in "$src"/*/; do
    [ -d "$src_skill" ] || continue
    name="$(basename "$src_skill")"
    rm -rf "$DEST_DIR/$name"
    cp -R "$src_skill" "$DEST_DIR/$name"
  done
}

if ! command -v git >/dev/null 2>&1; then
  fail "git is required"
fi

if [ -e "$SRC_DIR" ] && [ ! -d "$SRC_DIR/.git" ]; then
  log "removing incomplete .src"
  rm -rf "$SRC_DIR"
fi

if [ ! -d "$SRC_DIR/.git" ]; then
  mkdir -p "$DEST_DIR"
  if ! git clone --depth 1 --branch "$REF" --single-branch "$REPO_URL" "$SRC_DIR" >&2; then
    fail "git clone failed (network or ref '$REF')"
  fi
else
  if ! git -C "$SRC_DIR" fetch --depth 1 origin "$REF" >&2; then
    fail "git fetch failed (network or ref '$REF')"
  fi
  if ! git -C "$SRC_DIR" checkout FETCH_HEAD >&2; then
    fail "git checkout FETCH_HEAD failed"
  fi
fi

publish_skills
emit
