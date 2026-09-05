---
name: sync-rr-skills
description: Install or refresh the radikalreems catalog in this project.
disable-model-invocation: true
---

# Sync rr skills

## What this writes

```
<project>/
├── .gitignore                         # ignore radikalreems catalog copies
├── .agents/
│   └── skills/
│       └── radikalreems/              # from GitHub, gitignored
│           └── unslop/
│               └── SKILL.md
├── .claude/                           # second copy only if this folder already exists
│   └── skills/
│       └── radikalreems/
└── .cursor/
    └── skills/
        ├── sync-rr-skills/            # this skill, already present
        └── my-project-skill/          # yours, committed
            └── SKILL.md
```

Shared catalog always lands in `.agents/skills/radikalreems/`. Create `.agents/` if it is missing. If `$TARGET/.claude` is already a directory, write the same tree to `.claude/skills/radikalreems/`. Do not create `.claude/`. Project-only skills stay outside `radikalreems/`. Gitignore only those `radikalreems/` copies, not all of `.agents/skills/` or `.claude/skills/`.

The script shallow-clones `https://github.com/radikalreems/skills` into a temp dir and copies only that repo's `skills/` tree into each dest. README, `.cursor/`, and the rest of the repo stay out. Cursor and Codex load `.agents/skills/`. Claude Code loads `.claude/skills/`.

The catalog updates only when this skill runs.

## Prerequisites

- `git` on PATH
- `bash` (Git Bash on Windows)
- Network to `https://github.com/radikalreems/skills.git`
- `rsync` preferred; the script falls back to `cp`

## Steps

Check, then write. Publish only into the `radikalreems/` dests above. Leave every other folder under `.agents/skills/`, `.claude/skills/`, and `.cursor/skills/` as it is.

Run the asset script. Do not rewrite it.

### 1. Locate the target root

The target is this workspace's root. `$SKILL_DIR` is `$TARGET/.cursor/skills/sync-rr-skills`. That folder is already here (this skill).

Done when `TARGET` is the workspace root and `$SKILL_DIR/assets/sync-radikalreems-skills.sh` exists.

### 2. Update gitignore

Ensure `$TARGET/.gitignore` contains the line `.agents/skills/radikalreems/`. Create the file if needed. Append the line if missing.

If `$TARGET/.claude` is a directory, also ensure the line `.claude/skills/radikalreems/`.

Done when those dest lines are present and `.agents/skills/` and `.claude/skills/` as a whole are not ignored.

### 3. Sync the catalog

From `$TARGET`, with stderr visible:

```
bash "$SKILL_DIR/assets/sync-radikalreems-skills.sh"
```

The script tracks `main` unless `RADIKALREEMS_SKILLS_REF` is set in this shell to a branch or tag.

A non-zero exit means the fetch failed. Skill folders already under a dest stay on disk. Report the stderr reason.

Done when `.agents/skills/radikalreems/` contains catalog skill folders (for example `unslop/`), and `.claude/skills/radikalreems/` does too when `$TARGET/.claude` exists, or the failure has been reported.

### 4. Verify

- `ls "$TARGET/.agents/skills/radikalreems"` lists only catalog skill folders (no `.src`, no README)
- If `$TARGET/.claude` exists, `ls "$TARGET/.claude/skills/radikalreems"` lists the same catalog folders
- `git check-ignore -q .agents/skills/radikalreems` succeeds
- If the Claude dest was written, `git check-ignore -q .claude/skills/radikalreems` succeeds
- `git status` does not stage those dests
- Name collisions: folder names that exist both as `$TARGET/.agents/skills/<name>/` and `$TARGET/.agents/skills/radikalreems/<name>/`, or the same pair under `.claude/skills/` or `.cursor/skills/`. Mention them in the wrap-up. Leave both folders as they are.

Done when every check has a recorded result.

## Wrap-up for the user

Tell the user, in this order:

1. Reload so the agent picks up the skills. In Cursor, Command Palette is Ctrl+Shift+P (Cmd+Shift+P on Mac). Run **Developer: Reload Window**. Then check **Customize → Skills** for catalog skills such as `unslop`. Claude Code and Codex read the dest folders on the next session.
2. The catalog stays as this run left it. Run this skill again to refresh from GitHub.
3. To pin a branch or tag for a run, set `RADIKALREEMS_SKILLS_REF` in the same shell that runs the script.
4. Name collisions from step 4, if any.
5. Uninstall:
   - Delete `.agents/skills/radikalreems/`
   - Delete `.claude/skills/radikalreems/` if it exists
   - Remove the gitignore lines
   - Delete `.cursor/skills/sync-rr-skills/` if they no longer want the skill
   - Reload window
