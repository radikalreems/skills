#!/usr/bin/env bash
# Sync radikalreems/skills/skills into .cursor/skills/radikalreems.
# workspaceOpen hook: logs on stderr, "{}" on stdout.
set -euo pipefail

REPO_URL="https://github.com/radikalreems/skills.git"
REF="${RADIKALREEMS_SKILLS_REF:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST_DIR="$PROJECT_ROOT/.cursor/skills/radikalreems"
WORKDIR=""

log() {
  printf 'sync-radikalreems-skills: %s\n' "$*" >&2
}

emit() {
  printf '{}\n'
}

cleanup() {
  if [ -n "$WORKDIR" ] && [ -d "$WORKDIR" ]; then
    rm -rf "$WORKDIR"
  fi
}

fail() {
  log "$1"
  emit
  exit 1
}

trap cleanup EXIT

publish_skills() {
  local src="$1"
  local name dest_skill src_skill

  if [ ! -d "$src" ]; then
    fail "clone has no skills/ directory"
  fi

  mkdir -p "$DEST_DIR"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$src/" "$DEST_DIR/" >&2
    return
  fi

  for dest_skill in "$DEST_DIR"/*/; do
    [ -d "$dest_skill" ] || continue
    name="$(basename "$dest_skill")"
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

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/radikalreems-skills.XXXXXX")"
if ! git clone --depth 1 --branch "$REF" --single-branch "$REPO_URL" "$WORKDIR/repo" >&2; then
  fail "git clone failed (network or ref '$REF')"
fi

publish_skills "$WORKDIR/repo/skills"
emit
