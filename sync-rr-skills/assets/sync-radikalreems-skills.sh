#!/usr/bin/env bash
# Copy radikalreems/skills/skills into .agents/skills/radikalreems.
# If .claude exists, copy there too.
# Run from the project root.
set -euo pipefail

REPO_URL="https://github.com/radikalreems/skills.git"
REF="${RADIKALREEMS_SKILLS_REF:-main}"

PROJECT_ROOT="$(pwd)"
WORKDIR=""

log() {
  printf 'sync-radikalreems-skills: %s\n' "$*" >&2
}

cleanup() {
  if [ -n "$WORKDIR" ] && [ -d "$WORKDIR" ]; then
    rm -rf "$WORKDIR"
  fi
}

fail() {
  log "$1"
  exit 1
}

trap cleanup EXIT

collect_skills() {
  local src="$1"
  local staging="$2"
  local skill_md skill_dir name

  while IFS= read -r skill_md; do
    skill_dir="$(dirname "$skill_md")"
    name="$(basename "$skill_dir")"
    rm -rf "$staging/$name"
    cp -R "$skill_dir" "$staging/$name"
  done < <(find "$src" -mindepth 2 -maxdepth 3 -name SKILL.md)
}

publish_skills() {
  local src="$1"
  local dest="$2"
  local staging name dest_skill src_skill

  if [ ! -d "$src" ]; then
    fail "clone has no skills/ directory"
  fi

  staging="$(mktemp -d "${TMPDIR:-/tmp}/radikalreems-skills-flat.XXXXXX")"
  collect_skills "$src" "$staging"

  mkdir -p "$dest"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$staging/" "$dest/" >&2
    rm -rf "$staging"
    return
  fi

  for dest_skill in "$dest"/*/; do
    [ -d "$dest_skill" ] || continue
    name="$(basename "$dest_skill")"
    if [ ! -d "$staging/$name" ]; then
      rm -rf "$dest_skill"
    fi
  done

  for src_skill in "$staging"/*/; do
    [ -d "$src_skill" ] || continue
    name="$(basename "$src_skill")"
    rm -rf "$dest/$name"
    cp -R "$src_skill" "$dest/$name"
  done

  rm -rf "$staging"
}

if [ ! -d "$PROJECT_ROOT/.agents/skills/sync-rr-skills" ]; then
  fail "run from the project root (missing .agents/skills/sync-rr-skills)"
fi

if ! command -v git >/dev/null 2>&1; then
  fail "git is required"
fi

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/radikalreems-skills.XXXXXX")"
if ! git clone --depth 1 --branch "$REF" --single-branch "$REPO_URL" "$WORKDIR/repo" >&2; then
  fail "git clone failed (network or ref '$REF')"
fi

mkdir -p "$PROJECT_ROOT/.agents"
publish_skills "$WORKDIR/repo/skills" "$PROJECT_ROOT/.agents/skills/radikalreems"

if [ -d "$PROJECT_ROOT/.claude" ]; then
  publish_skills "$WORKDIR/repo/skills" "$PROJECT_ROOT/.claude/skills/radikalreems"
fi
