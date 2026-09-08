# Skills

A skill is a folder with a `SKILL.md` that tells an agent how to do one job. [`skills/`](skills/) is the full catalog, split into `engineering/` and `productivity/`.

## Catalog

### Engineering

- [`code-review`](skills/engineering/code-review/). Reviews a diff on two axes: repo standards and the originating spec.
- [`codebase-design`](skills/engineering/codebase-design/). Shared vocabulary for designing deep modules, seams, and interfaces.
- [`domain-modeling`](skills/engineering/domain-modeling/). Builds and sharpens the project's domain model, glossary, and ADRs.
- [`grill-with-docs`](skills/engineering/grill-with-docs/). Starts a grilling interview and writes glossary and ADRs as decisions land.
- [`research`](skills/engineering/research/). Investigates a question against primary sources and writes the findings as a Markdown file.
- [`setup-workflow`](skills/engineering/setup-workflow/). Configures this repo's issue tracker, triage labels, and domain docs.
- [`tdd`](skills/engineering/tdd/). Test-driven red-green loop: write a failing test, then just enough code to pass it.
- [`triage`](skills/engineering/triage/). Moves issues through triage roles and writes agent-ready briefs.
- [`wayfinder`](skills/engineering/wayfinder/). Plans a large effort as a shared map of decision tickets on the issue tracker.

### Productivity

- [`grill-me`](skills/productivity/grill-me/). Starts a relentless interview to sharpen a plan. Calls `grilling`.
- [`grilling`](skills/productivity/grilling/). Runs that interview in rounds until every branch of the design is settled.
- [`handoff`](skills/productivity/handoff/). Compacts this conversation into a file another agent can pick up.
- [`teach`](skills/productivity/teach/). Teaches a topic across sessions in the current directory.
- [`to-questionnaire`](skills/productivity/to-questionnaire/). Turns a gap you cannot fill into a Markdown questionnaire for someone else.
- [`unslop`](skills/productivity/unslop/). Cuts AI tells from writing.
- [`wait-what`](skills/productivity/wait-what/). Re-pitches the last message in simpler English, using the project's vocabulary.
- [`writing-for-agents`](skills/productivity/writing-for-agents/). How to write skills, `AGENTS.md`, and other docs an agent will run.

## Installing

### One skill

Copy that skill's folder from `skills/engineering/` or `skills/productivity/` into the project:

- `.agents/skills/` for Cursor and Codex
- `.claude/skills/` for Claude Code
- `.cursor/skills/` if that is where the project already keeps skills

### The whole catalog

Copy [`sync-rr-skills/`](sync-rr-skills/) using the same steps, then run `sync-rr-skills`.

It always writes the catalog to `.agents/skills/radikalreems/` and treats that as the source of truth. If the project already has a `.claude/` folder, it also writes a copy to `.claude/skills/radikalreems/`. Each skill lands as its own folder there, not under `engineering/` or `productivity/`.

When this repo updates, run `sync-rr-skills` again.

## Note

If you use Claude Code and Cursor in the same project, Cursor also reads `.claude/skills/`. Each catalog skill shows up twice. There is no clean fix for that.
