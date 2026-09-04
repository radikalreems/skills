# Skills

Each catalog skill is a folder under `skills/` with a `SKILL.md`. That folder is the library. The sync skill copies only `skills/` into other projects.

`.cursor/skills/` only loads skills this repo needs while you work on it. `unslop` and `writing-for-agents` are in there. The rest of the library is not.

`sync-rr-skills/` sits at the repo root, not under `skills/`. Copy that folder into another project and run the skill there. It is not part of the synced catalog.

## Layout

```
.
├── README.md
├── AGENTS.md
├── sync-rr-skills/         # copy and run in another project
├── .cursor/skills/         # only skills this repo needs
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

## Installing the catalog into another project

1. Copy [`sync-rr-skills/`](sync-rr-skills/) into `<that-repo>/.cursor/skills/sync-rr-skills/`.
2. Open that repo in Cursor and run the `sync-rr-skills` skill.

That writes `<that-repo>/.cursor/skills/radikalreems/` from `skills/` on GitHub. Run the skill again to refresh. Opening the project does not sync.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Use lowercase letters, numbers, and hyphens for `<skill-name>`.
3. Follow the frontmatter and authoring rules in [AGENTS.md](AGENTS.md).

Add it to `.cursor/skills/` only if working on this repo should load it.
