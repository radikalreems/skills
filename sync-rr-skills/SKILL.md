---
name: sync-rr-skills
description: Install or refresh the radikalreems catalog in this project.
disable-model-invocation: true
---

# Sync rr skills

## What this writes

```
<project>/
├── .git/info/exclude                  # local patterns, never committed
├── .agents/                           # local
│   └── skills/
│       ├── sync-rr-skills/            # this skill, already present
│       ├── my-project-skill/          # yours, stays on this clone
│       │   └── SKILL.md
│       └── radikalreems/              # from GitHub
│           └── unslop/
│               └── SKILL.md
└── .claude/                           # second catalog copy only if this folder already exists
    └── skills/
        └── radikalreems/
```

Shared catalog always lands in `.agents/skills/radikalreems/`. Create `.agents/` if it is missing. If `$TARGET/.claude` is already a directory, write the same tree to `.claude/skills/radikalreems/`. Do not create `.claude/`. Project-only skills stay outside `radikalreems/`. Record `.agents/` in `.git/info/exclude`. When `.claude` already exists, also record `.claude/skills/radikalreems/` there. The committed `.gitignore` stays as it is. `.claude/skills/` as a whole stays trackable.

The script shallow-clones `https://github.com/radikalreems/skills` into a temp dir, finds each skill folder under `skills/` (including `engineering/` and `productivity/`), and copies those folders into each dest. Category wrappers stay out. README and the rest of the repo stay out. Cursor and Codex load `.agents/skills/`. Claude Code loads `.claude/skills/`.

The catalog updates only when this skill runs.

## Prerequisites

- `git` on PATH
- `bash` (Git Bash on Windows)
- Network to `https://github.com/radikalreems/skills.git`
- `rsync` preferred; the script falls back to `cp`

## Steps

Check, then write. Publish only into the `radikalreems/` dests above. Leave every other folder under `.agents/skills/` and `.claude/skills/` as it is.

Run the asset script. Do not rewrite it.

### 1. Locate the target root

The target is this workspace's root. `$SKILL_DIR` is `$TARGET/.agents/skills/sync-rr-skills`. That folder is already here (this skill).

Done when `TARGET` is the workspace root and `$SKILL_DIR/assets/sync-radikalreems-skills.sh` exists.

### 2. Keep the catalog local

Append any missing pattern to `$TARGET/.git/info/exclude`. Create that file when it is absent. The committed `.gitignore` stays as it is.

```
.agents/
```

When `$TARGET/.claude` is a directory, also append `.claude/skills/radikalreems/` if that line is absent.

A parent pattern that already covers a dest counts as present. `setup-workflow` may already have written `.agents/`.

Done when `git check-ignore -q --no-index .agents/skills/radikalreems` succeeds, `.claude/skills/radikalreems` is ignored when `.claude` exists, and `.gitignore` has no line for these paths.

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
- `git check-ignore -q --no-index .agents/skills/radikalreems` succeeds
- If the Claude dest was written, `git check-ignore -q --no-index .claude/skills/radikalreems` succeeds
- `git status` does not stage those dests
- Name collisions: folder names that exist both as `$TARGET/.agents/skills/<name>/` and `$TARGET/.agents/skills/radikalreems/<name>/`, or the same pair under `.claude/skills/`. Mention them in the wrap-up. Leave both folders as they are.

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
   - Remove the `.agents/` and `.claude/skills/radikalreems/` lines from `.git/info/exclude`
   - Delete `.agents/skills/sync-rr-skills/` if they no longer want the skill
   - Reload window
