#!/usr/bin/env bash
# Sync radikalreems/skills into this project's vendor plugin dir.
# Cursor workspaceOpen hook: JSON on stdout, logs on stderr.
set -euo pipefail

REPO_URL="https://github.com/radikalreems/skills.git"
REF="${RADIKALREEMS_SKILLS_REF:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VENDOR_DIR="$PROJECT_ROOT/.cursor/radikalreems"
SRC_DIR="$VENDOR_DIR/.src"
SKILLS_DIR="$VENDOR_DIR/skills"
PLUGIN_JSON="$VENDOR_DIR/.cursor-plugin/plugin.json"

log() {
  printf 'sync-radikalreems-skills: %s\n' "$*" >&2
}

plugin_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -aw "$VENDOR_DIR"
  else
    printf '%s' "$VENDOR_DIR"
  fi
}

emit_plugin_paths() {
  local escaped
  escaped="$(printf '%s' "$(plugin_path)" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  printf '{"pluginPaths":["%s"]}\n' "$escaped"
}

vendor_usable() {
  local d
  for d in "$SKILLS_DIR"/*/; do
    if [ -d "$d" ]; then
      return 0
    fi
  done
  return 1
}

fail() {
  log "$1"
  if vendor_usable; then
    emit_plugin_paths
  fi
  exit 1
}

write_plugin_json() {
  mkdir -p "$(dirname "$PLUGIN_JSON")"
  cat > "$PLUGIN_JSON" <<'EOF'
{
  "name": "radikalreems-skills",
  "version": "0.1.0",
  "description": "Shared skills synced from radikalreems/skills",
  "author": { "name": "radikalreems" },
  "repository": "https://github.com/radikalreems/skills",
  "skills": "./skills"
}
EOF
}

publish_skills() {
  local src="$SRC_DIR/skills"
  local name dest_skill src_skill

  if [ ! -d "$src" ]; then
    fail "clone has no skills/ directory"
  fi

  mkdir -p "$SKILLS_DIR"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$src/" "$SKILLS_DIR/" >&2
    return
  fi

  for dest_skill in "$SKILLS_DIR"/*/; do
    [ -d "$dest_skill" ] || continue
    name="$(basename "$dest_skill")"
    if [ ! -d "$src/$name" ]; then
      rm -rf "$dest_skill"
    fi
  done

  for src_skill in "$src"/*/; do
    [ -d "$src_skill" ] || continue
    name="$(basename "$src_skill")"
    rm -rf "$SKILLS_DIR/$name"
    cp -R "$src_skill" "$SKILLS_DIR/$name"
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
  mkdir -p "$VENDOR_DIR"
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
write_plugin_json

if ! vendor_usable; then
  fail "publish produced no skill folders"
fi

emit_plugin_paths
