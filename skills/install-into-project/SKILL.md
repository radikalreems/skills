---
name: install-into-project
description: Install the radikalreems catalog into this project.
disable-model-invocation: true
---

# Install into project

## What this sets up

```
<project>/
├── .gitignore                         # ignore .cursor/skills/radikalreems/
└── .cursor/
    ├── hooks.json                     # workspaceOpen → sync script
    ├── hooks/
    │   └── sync-radikalreems-skills.sh
    └── skills/
        ├── my-project-skill/          # yours, committed
        │   └── SKILL.md
        └── radikalreems/              # from GitHub, gitignored
            └── unslop/
                └── SKILL.md
```

Shared catalog lands in `.cursor/skills/radikalreems/`. Project-only skills stay beside it, not inside it. Gitignore only `.cursor/skills/radikalreems/`, not all of `.cursor/skills/`.

The hook shallow-fetches `https://github.com/radikalreems/skills` and rsyncs that repo's `skills/` tree into `.cursor/skills/radikalreems/`. Cursor loads each folder there that contains `SKILL.md`.

## Prerequisites

- `git` on PATH
- `bash` (Git Bash on Windows)
- Network to `https://github.com/radikalreems/skills.git`
- `rsync` preferred; the script falls back to `cp`

## Steps

Check, then write. Ask before changing an existing `.cursor/hooks.json`. Publish only into `.cursor/skills/radikalreems/`. Leave every other folder under `.cursor/skills/` as it is.

If `$TARGET/.cursor/radikalreems` exists (old plugin vendor), ask, then delete it and drop `.cursor/radikalreems/` from `.gitignore`.

### 1. Locate the target root

The target is this workspace's root.

If that root contains both `skills/install-into-project/SKILL.md` and an `AGENTS.md` that says skills live in `skills/`, this workspace is the catalog. Ask for the target path.

Done when `TARGET` is an absolute path to the project root.

### 2. Create directories

```
.cursor/hooks/
.cursor/skills/
```

Done when both exist.

### 3. Write the sync script

This skill's folder is the directory that contains this `SKILL.md` (catalog: `skills/install-into-project/`; user skills: `~/.cursor/skills/install-into-project/`).

Copy `$SKILL_DIR/assets/sync-radikalreems-skills.sh` to `$TARGET/.cursor/hooks/sync-radikalreems-skills.sh`. If this skill folder is not on disk, write the file from the canonical script below. Use LF line endings.

`chmod +x` the script. On Windows, `git update-index --chmod=+x` if you stage it and `chmod` is missing.

Done when the hook script matches the canonical script and is executable.

### 4. Merge hooks.json

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

### 5. Update gitignore

Ensure `$TARGET/.gitignore` contains the line `.cursor/skills/radikalreems/`. Create the file if needed. Append the line if missing.

Done when that line is present and `.cursor/skills/` as a whole is not ignored.

### 6. Run sync once

From `$TARGET`, with stderr visible:

```bash
bash .cursor/hooks/sync-radikalreems-skills.sh
```

Stdout is `{}`. A non-zero exit means the fetch failed; skill folders already under `.cursor/skills/radikalreems/` stay on disk. Report the stderr reason.

Done when `.cursor/skills/radikalreems/` contains catalog skill folders (for example `unslop/`), or the failure has been reported.

### 7. Verify

- `ls "$TARGET/.cursor/skills/radikalreems"` lists catalog skill folders and may list `.src`
- `hooks.json` includes the `workspaceOpen` entry above
- `git check-ignore -q .cursor/skills/radikalreems` succeeds
- `git status` does not stage `.cursor/skills/radikalreems/`
- Name collisions: folder names that exist both as `$TARGET/.cursor/skills/<name>/` and `$TARGET/.cursor/skills/radikalreems/<name>/`. Mention them in the wrap-up. Leave both folders as they are.

Done when every check has a recorded result.

## Canonical file contents

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

Clone cache lives at `.cursor/skills/radikalreems/.src` (gitignored with the catalog). Publish copies `$SRC/skills/` onto `.cursor/skills/radikalreems/` and leaves `.src` in place. The script never writes outside that folder.

```bash
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
```

## Wrap-up for the user

Tell the user, in this order:

1. Run **Developer: Reload Window**, then check **Customize → Skills** for catalog skills such as `unslop`.
2. Track in git: `.cursor/hooks.json`, `.cursor/hooks/sync-radikalreems-skills.sh`, and the gitignore line. Leave `.cursor/skills/radikalreems/` untracked.
3. Updates: push to `radikalreems/skills` on GitHub. The next local workspace open fetches `main` (or the pinned ref).
4. Pin a ref by setting `RADIKALREEMS_SKILLS_REF` in the environment Cursor inherits (`RADIKALREEMS_SKILLS_REF=some-branch`).
5. Local Cursor auto-syncs on open. Cloud Agents do not run `workspaceOpen`, so they will not see these skills unless a different distribution path is used later.
6. Name collisions from step 7, if any.
7. Uninstall:
   - Remove the `workspaceOpen` entry whose command is `.cursor/hooks/sync-radikalreems-skills.sh`
   - Delete `.cursor/hooks/sync-radikalreems-skills.sh` if unused
   - Delete `.cursor/skills/radikalreems/`
   - Remove the gitignore line
   - Reload window

## Do not

Publish the catalog only into `.cursor/skills/radikalreems/`.

- Write a `plugin.json` or print `pluginPaths`
- Sync onto `.cursor/skills/` itself
- Symlink `radikalreems/` to a home clone of the catalog
- Use `npx skills add` as the main path
- Copy catalog `SKILL.md` files into `.cursor/skills/<name>/`
- Delete anything under `.cursor/skills/` except inside `radikalreems/` during sync
- Commit `.cursor/skills/radikalreems/`
- Put secrets in the sync script
- Rename project-local skills to resolve collisions
