---
name: sync-rr-skills
description: Install or refresh the radikalreems catalog in this project.
disable-model-invocation: true
---

# Sync rr skills

## What this writes

```
<project>/
├── .gitignore                         # ignore .cursor/skills/radikalreems/
└── .cursor/
    └── skills/
        ├── sync-rr-skills/            # this skill, already present
        ├── my-project-skill/          # yours, committed
        │   └── SKILL.md
        └── radikalreems/              # from GitHub, gitignored
            └── unslop/
                └── SKILL.md
```

Shared catalog lands in `.cursor/skills/radikalreems/`. Project-only skills stay beside it, not inside it. Gitignore only `.cursor/skills/radikalreems/`, not all of `.cursor/skills/`.

The script shallow-clones `https://github.com/radikalreems/skills` into a temp dir and copies only that repo's `skills/` tree into `.cursor/skills/radikalreems/`. README, `.cursor/`, and the rest of the repo stay out. Cursor loads each folder there that contains `SKILL.md`.

The catalog updates only when this skill runs.

## Prerequisites

- `git` on PATH
- `bash` (Git Bash on Windows)
- Network to `https://github.com/radikalreems/skills.git`
- `rsync` preferred; the script falls back to `cp`

## Steps

Check, then write. Publish only into `.cursor/skills/radikalreems/`. Leave every other folder under `.cursor/skills/` as it is.

Run the asset script. Do not rewrite it.

### 1. Locate the target root

The target is this workspace's root. `$SKILL_DIR` is `$TARGET/.cursor/skills/sync-rr-skills`. That folder is already here (this skill).

Done when `TARGET` is the workspace root and `$SKILL_DIR/assets/sync-radikalreems-skills.sh` exists.

### 2. Update gitignore

Ensure `$TARGET/.gitignore` contains the line `.cursor/skills/radikalreems/`. Create the file if needed. Append the line if missing.

Done when that line is present and `.cursor/skills/` as a whole is not ignored.

### 3. Sync the catalog

From `$TARGET`, with stderr visible:

```
bash "$SKILL_DIR/assets/sync-radikalreems-skills.sh"
```

The script tracks `main` unless `RADIKALREEMS_SKILLS_REF` is set in this shell to a branch or tag.

A non-zero exit means the fetch failed. Skill folders already under `.cursor/skills/radikalreems/` stay on disk. Report the stderr reason.

Done when `.cursor/skills/radikalreems/` contains catalog skill folders (for example `unslop/`), or the failure has been reported.

### 4. Verify

- `ls "$TARGET/.cursor/skills/radikalreems"` lists only catalog skill folders (no `.src`, no README)
- `git check-ignore -q .cursor/skills/radikalreems` succeeds
- `git status` does not stage `.cursor/skills/radikalreems/`
- Name collisions: folder names that exist both as `$TARGET/.cursor/skills/<name>/` and `$TARGET/.cursor/skills/radikalreems/<name>/`. Mention them in the wrap-up. Leave both folders as they are.

Done when every check has a recorded result.

## Wrap-up for the user

Tell the user, in this order:

1. Reload so Cursor picks up the skills. Command Palette is Ctrl+Shift+P (Cmd+Shift+P on Mac). Run **Developer: Reload Window**. Then check **Customize → Skills** for catalog skills such as `unslop`.
2. The catalog stays as this run left it. Run this skill again to refresh from GitHub.
3. To pin a branch or tag for a run, set `RADIKALREEMS_SKILLS_REF` in the same shell that runs the script.
4. Name collisions from step 4, if any.
5. Uninstall:
   - Delete `.cursor/skills/radikalreems/`
   - Remove the gitignore line
   - Delete `.cursor/skills/sync-rr-skills/` if they no longer want the skill
   - Reload window
