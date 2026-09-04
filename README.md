# Skills

Each skill is a folder under `skills/` with a `SKILL.md`. That folder is the library.

`.cursor/skills/` only loads skills this repo needs while you work on it. `unslop` and `writing-for-agents` are in there. The rest of the library is not.

## Layout

```
.
├── README.md
├── AGENTS.md
├── .cursor/skills/   # only skills this repo needs
└── skills/
    └── skill-name/
        ├── SKILL.md
        └── ...optional extras
```

## Using a skill

Name the skill in Cursor, or copy/symlink its folder into one of these:

| Scope | Path |
| --- | --- |
| Personal (all projects) | `~/.cursor/skills/skill-name/` |
| Another project | `<that-repo>/.cursor/skills/skill-name/` |

Skip `~/.cursor/skills-cursor/`. Cursor keeps its built-in skills there.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Use lowercase letters, numbers, and hyphens for `<skill-name>`.
3. Follow the frontmatter and authoring rules in [AGENTS.md](AGENTS.md).

Add it to `.cursor/skills/` only if working on this repo should load it.
