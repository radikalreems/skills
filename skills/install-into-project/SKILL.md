---
name: install-into-project
description: >
  Wire radikalreems/skills into another Cursor project so GitHub stays
  the source of truth. Use when the user wants shared skills in a repo,
  a workspaceOpen sync hook, or to install radikalreems skills without
  copying SKILL.md files into the project.
---

# Install into project

Playbook for wiring the radikalreems catalog into a target Cursor project. GitHub stays the source of truth. Project-owned skills stay in the target's `.cursor/skills/`. Shared skills live in the target's `.cursor/radikalreems/` and are never the source of truth.

**Chicken-and-egg.** This skill must already be in context: the catalog repo is open, this folder is copied to `~/.cursor/skills/install-into-project`, or the user pasted the playbook. After install, later updates come from GitHub via the hook. Skip re-running this skill to refresh vendor skills.

## When to use

The user wants shared radikalreems skills in another repo, a `workspaceOpen` sync hook, or GitHub-synced skills instead of copied `SKILL.md` files.

## What this sets up

```
<target>/
├── .gitignore                      # contains .cursor/radikalreems/
└── .cursor/
    ├── hooks.json                  # workspaceOpen -> sync script
    ├── hooks/
    │   └── sync-radikalreems-skills.sh
    ├── skills/                     # project-owned only
    └── radikalreems/               # vendor dir, gitignored
        ├── .cursor-plugin/
        │   └── plugin.json
        ├── .src/                   # shallow clone of radikalreems/skills
        └── skills/                 # published catalog
```

Cursor loads vendor skills because the vendor dir is a plugin (`plugin.json` + `skills/`) and the hook prints `{ "pluginPaths": ["<absolute path to .cursor/radikalreems>"] }`. Cursor does not load `.cursor/radikalreems/**` as project skills.

## Prerequisites

- `git` on PATH
- `bash` (Git Bash on Windows)
- Network to `https://github.com/radikalreems/skills.git`
- Target is a Cursor workspace
- User wants GitHub sync, not a symlink to a local clone
- `rsync` preferred; the script falls back to `cp`

## Steps

Check, then write. Ask before changing an existing `.cursor/hooks.json` or an unexpected vendor dir. An expected vendor dir has `.cursor-plugin/plugin.json` with `"name": "radikalreems-skills"`. Leave `.cursor/skills/` untouched aside from creating the empty directory.

### 1. Locate the target root

The target is the workspace root of the project being wired.

If that root contains both `skills/install-into-project/SKILL.md` and an `AGENTS.md` that says skills live in `skills/`, this workspace is the catalog. Ask for the target path.

Done when `TARGET` is an absolute path to that project root.

### 2. Create directories

```
.cursor/skills/
.cursor/hooks/
.cursor/radikalreems/.cursor-plugin/
```

Put vendor files only under `.cursor/radikalreems/` and `.cursor/hooks/`.

Done when those three directories exist.

### 3. Write plugin.json

Write [Canonical file contents](#canonical-file-contents) `plugin.json` to `$TARGET/.cursor/radikalreems/.cursor-plugin/plugin.json`.

Done when that file matches the canonical JSON.

### 4. Write the sync script

This skill's folder is the directory that contains this `SKILL.md` (catalog: `skills/install-into-project/`; user skills: `~/.cursor/skills/install-into-project/`).

Copy `$SKILL_DIR/assets/sync-radikalreems-skills.sh` to `$TARGET/.cursor/hooks/sync-radikalreems-skills.sh`. If this skill folder is not on disk, write the file from the canonical script below. Use LF line endings.

`chmod +x` the script. On Windows, `git update-index --chmod=+x` if you stage it and `chmod` is missing.

Done when the hook script matches the canonical script and is executable.

### 5. Merge hooks.json

Path: `$TARGET/.cursor/hooks.json`. Command paths are relative to the target root.

If the file is missing, write the canonical `hooks.json`.

If the file exists, parse JSON first. If JSON is invalid, stop and show the parse error. Leave the file as-is.

If an entry already has `command` equal to `.cursor/hooks/sync-radikalreems-skills.sh`, leave the file. If that command is missing, ask, then add the entry. Keep every other hook. Preserve `version` and sibling events.

Merge with `python3` (or `python`):

```python
import json, sys
path = sys.argv[1]
cmd = ".cursor/hooks/sync-radikalreems-skills.sh"
with open(path, encoding="utf-8") as f:
    data = json.load(f)
if not isinstance(data, dict):
    raise SystemExit("hooks.json root must be an object")
hooks = data.setdefault("hooks", {})
if not isinstance(hooks, dict):
    raise SystemExit("hooks must be an object")
wo = hooks.setdefault("workspaceOpen", [])
if not isinstance(wo, list):
    raise SystemExit("workspaceOpen must be an array")
if not any(isinstance(h, dict) and h.get("command") == cmd for h in wo):
    wo.append({"command": cmd, "timeout": 60})
data.setdefault("version", 1)
with open(path, "w", encoding="utf-8", newline="\n") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
```

Done when `hooks.json` is valid JSON and contains that `workspaceOpen` command, and every previously present hook is still present.

### 6. Update gitignore

Ensure `$TARGET/.gitignore` contains the line `.cursor/radikalreems/`. Create the file if needed. Append the line if missing. Leave other `.cursor/` paths tracked.

Done when that line is present and `.cursor/` as a whole is not ignored.

### 7. Run sync once

From `$TARGET`, with stderr visible:

```bash
bash .cursor/hooks/sync-radikalreems-skills.sh
```

Stdout must be a single JSON object with `pluginPaths` pointing at `$TARGET/.cursor/radikalreems`. A non-zero exit with that JSON means stale vendor skills are still loadable; tell the user the stderr reason. A non-zero exit with no JSON means the first sync failed and vendor skills are missing.

Done when `.cursor/radikalreems/skills/` contains skill folders, or the failure and fallback have been reported.

### 8. Verify

- `ls "$TARGET/.cursor/radikalreems/skills"` lists catalog skill folders
- `hooks.json` includes the `workspaceOpen` entry above
- `git check-ignore -q .cursor/radikalreems` succeeds (vendor dir ignored)
- `git status` does not stage `.cursor/radikalreems/`
- Name collisions: folder names that exist in both `.cursor/skills/` and `.cursor/radikalreems/skills/`. Mention them in the wrap-up. Leave both folders as they are.

Done when every check has a recorded result.

## Canonical file contents

### plugin.json

`$TARGET/.cursor/radikalreems/.cursor-plugin/plugin.json`

```json
{
  "name": "radikalreems-skills",
  "version": "0.1.0",
  "description": "Shared skills synced from radikalreems/skills",
  "author": { "name": "radikalreems" },
  "repository": "https://github.com/radikalreems/skills",
  "skills": "./skills"
}
```

The sync script also writes this file so a machine that only has the committed hook still gets a plugin wrapper.

### hooks.json

`$TARGET/.cursor/hooks.json` when the file is new

```json
{
  "version": 1,
  "hooks": {
    "workspaceOpen": [
      {
        "command": ".cursor/hooks/sync-radikalreems-skills.sh",
        "timeout": 60
      }
    ]
  }
}
```

### sync-radikalreems-skills.sh

`$TARGET/.cursor/hooks/sync-radikalreems-skills.sh`

```bash
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
```

Sync behavior the script already implements:

- Source: `https://github.com/radikalreems/skills.git`, ref `${RADIKALREEMS_SKILLS_REF:-main}`
- First run: `git clone --depth 1 --branch "$REF" --single-branch` into `.cursor/radikalreems/.src`
- Later runs: `git fetch --depth 1 origin "$REF"` then `checkout FETCH_HEAD`
- Publish with `rsync -a --delete` from `.src/skills/` to `.cursor/radikalreems/skills/`, or the `cp` path that deletes stale skill folders
- Missing `git` or a failed network call: non-zero exit, short stderr message, `pluginPaths` only when published skills already exist
- Success and stale fallback: only the JSON object on stdout
- Hook timeout is 60 seconds; the script stays on a shallow fetch
- The script never deletes the whole vendor dir

## Wrap-up for the user

Tell the user, in this order:

1. Run **Developer: Reload Window**, then check **Customize → Skills / Plugins** for `radikalreems-skills`.
2. Track in git: `.cursor/hooks.json`, `.cursor/hooks/sync-radikalreems-skills.sh`, and the gitignore line. Leave the vendor dir untracked.
3. Updates: push to `radikalreems/skills` on GitHub. The next local workspace open fetches `main` (or the pinned ref).
4. Pin a ref by setting `RADIKALREEMS_SKILLS_REF` in the environment Cursor inherits (`RADIKALREEMS_SKILLS_REF=some-branch`).
5. Local Cursor auto-syncs on open. Cloud Agents do not run `workspaceOpen`. Cloud Agents will not see vendor skills unless a different distribution path is used later.
6. Name collisions from step 8, if any.
7. Uninstall:
   - Remove the `workspaceOpen` entry whose command is `.cursor/hooks/sync-radikalreems-skills.sh`
   - Delete `.cursor/hooks/sync-radikalreems-skills.sh` if unused
   - Delete `.cursor/radikalreems/`
   - Remove the gitignore line
   - Reload window

## Do not

Load shared skills through the vendor plugin path in this playbook.

- Symlink the vendor dir to a home clone of the catalog
- Use `npx skills add` as the main path
- Copy catalog `SKILL.md` files into `.cursor/skills/`
- Sync into `.cursor/skills/` or `.cursor/radikalskills/`
- Delete anything under `.cursor/skills/`
- Commit the vendor checkout
- Put secrets in the sync script
- Rename project-local skills to resolve collisions
