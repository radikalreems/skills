# Agent instructions

This repo is a library of Cursor agent skills. Catalog skills live in `skills/`. The hook that installs this library into other projects copies only that folder.

## Repo map

- `README.md` — human-facing overview and how to install/use skills.
- `AGENTS.md` — this file. Follow it when adding, editing, or applying skills.
- `skills/<skill-name>/` — one folder per catalog skill. The folder name should match the skill `name`.
- `install-into-project/` — playbook that wires this catalog into another project. Stay out of `skills/` so the sync hook does not ship it. Reach it when installing shared skills into a target repo.

## Skill layout

```
skills/skill-name/
├── SKILL.md          # required
├── reference.md      # optional, detailed docs
├── examples.md       # optional
└── scripts/          # optional utilities
```

Keep references one level deep from `SKILL.md`. Do not nest further docs that the agent has to chase.

## SKILL.md format

Every skill needs YAML frontmatter and a markdown body:

```markdown
---
name: skill-name
description: What the skill does and when to use it. Include trigger terms.
disable-model-invocation: true
---

# Skill Name

## Instructions
...
```

- `name`: max 64 characters, lowercase letters, numbers, and hyphens only.
- `description`: max 1024 characters, third person, both what and when. This is how the agent discovers the skill.
- Default `disable-model-invocation: true` so the skill loads only when named. Omit it only when the agent should auto-invoke from context.

## Authoring rules

- Assume the agent is already capable. Add only knowledge it would not already have.
- Keep `SKILL.md` under 500 lines. Put long reference material in sibling files and link them.
- Prefer concrete steps, templates, and examples over background explanation.
- Use one term consistently. Do not mix synonyms for the same concept.
- Use POSIX-style paths in instructions (`scripts/helper.py`), not Windows backslashes.
- If the user gives exact wording for a skill, use it verbatim.

## Workflow for new skills

1. Confirm purpose, trigger scenarios, and any required output format.
2. Create `skills/<skill-name>/SKILL.md` with frontmatter.
3. Add sibling files or scripts only when they earn their keep.
4. Check that the description includes trigger terms and that links are one level deep.

## What not to do

- Do not create skills in `~/.cursor/skills-cursor/`.
- Do not dump multiple unrelated workflows into one skill.
- Do not put time-sensitive dates or "use X before date Y" in the main path. Park old approaches under an "Old patterns" section if needed.
