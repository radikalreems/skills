# Skills

A skill is a folder with a `SKILL.md` that tells an agent how to do one job. [`skills/`](skills/) is the full catalog.

## Catalog

- [`grill-me`](skills/grill-me/). Starts a relentless interview to sharpen a plan. Calls `grilling`.
- [`grilling`](skills/grilling/). Runs that interview in rounds until every branch of the design is settled.
- [`handoff`](skills/handoff/). Compacts this conversation into a file another agent can pick up.
- [`teach`](skills/teach/). Teaches a topic across sessions in the current directory.
- [`to-questionnaire`](skills/to-questionnaire/). Turns a gap you cannot fill into a Markdown questionnaire for someone else.
- [`unslop`](skills/unslop/). Cuts AI tells from writing.
- [`wait-what`](skills/wait-what/). Re-pitches the last message in simpler English, using the project's vocabulary.
- [`writing-for-agents`](skills/writing-for-agents/). How to write skills, `AGENTS.md`, and other docs an agent will run.

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
