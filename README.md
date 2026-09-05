# Skills

A skill is a folder with a `SKILL.md` that tells an agent how to do one job. [`skills/`](skills/) is the full catalog.

## Installing

### One skill

Copy that skill's folder from `skills/` into the project:

- `.agents/skills/` for Cursor and Codex
- `.claude/skills/` for Claude Code
- `.cursor/skills/` if that is where the project already keeps skills

### The whole catalog

Copy [`sync-rr-skills/`](sync-rr-skills/) using the same steps, then run `sync-rr-skills`.

It always writes the catalog to `.agents/skills/radikalreems/` and treats that as the source of truth. If the project already has a `.claude/` folder, it also writes a copy to `.claude/skills/radikalreems/`.

When this repo updates, run `sync-rr-skills` again.
