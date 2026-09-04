# Skills

A collection of Cursor agent skills.

Each skill is a folder under `skills/` with a `SKILL.md` that teaches the agent how to do a specific task.

## Layout

```
.
├── README.md
├── AGENTS.md
└── skills/
    └── skill-name/
        ├── SKILL.md
        └── ...optional extras
```

## Using a skill

Point Cursor at a skill by name, or copy/symlink a skill folder into one of these locations:

| Scope | Path |
| --- | --- |
| Personal (all projects) | `~/.cursor/skills/skill-name/` |
| Project (this repo or another) | `.cursor/skills/skill-name/` |

Do not put skills in `~/.cursor/skills-cursor/`. That directory is reserved for Cursor's built-in skills.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Use lowercase letters, numbers, and hyphens for `<skill-name>`.
3. Follow the frontmatter and authoring rules in [AGENTS.md](AGENTS.md).
