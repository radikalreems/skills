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
        ├── install-into-project/      # this skill, already present
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

Assets live in `$SKILL_DIR/assets/`. Copy those files. Do not rewrite them.

### 1. Locate the target root

The target is this workspace's root. `$SKILL_DIR` is `$TARGET/.cursor/skills/install-into-project`. That folder is already here (this skill).

Done when `TARGET` is the workspace root and `$SKILL_DIR/assets/sync-radikalreems-skills.sh` exists.

### 2. Ensure `.cursor/hooks/`

`.cursor/skills/` already exists. Leave it.

If `$TARGET/.cursor/hooks` is missing, create it. If it exists, leave it.

Done when `$TARGET/.cursor/hooks` is a directory.

### 3. Write the sync script

Copy `$SKILL_DIR/assets/sync-radikalreems-skills.sh` to `$TARGET/.cursor/hooks/sync-radikalreems-skills.sh`. Use LF line endings.

`chmod +x` the copy. On Windows, `git update-index --chmod=+x` if you stage it and `chmod` is missing.

Done when the dest file matches the asset and is executable.

### 4. Merge hooks.json

Path: `$TARGET/.cursor/hooks.json`. Command paths are relative to the target root.

If the file is missing, copy `$SKILL_DIR/assets/hooks.json` there.

If the file exists, ask, then run:

```
python3 "$SKILL_DIR/assets/merge-hooks.py" "$TARGET/.cursor/hooks.json"
```

Use `python` if `python3` is missing. If the script exits non-zero, stop and show stderr. Leave the file as-is.

Done when `hooks.json` is valid JSON, contains a `workspaceOpen` command equal to `.cursor/hooks/sync-radikalreems-skills.sh`, and every previously present hook is still present.

### 5. Update gitignore

Ensure `$TARGET/.gitignore` contains the line `.cursor/skills/radikalreems/`. Create the file if needed. Append the line if missing.

Done when that line is present and `.cursor/skills/` as a whole is not ignored.

### 6. Run sync once

From `$TARGET`, with stderr visible:

```
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
