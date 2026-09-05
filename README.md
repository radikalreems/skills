# Skills

Each catalog skill is a folder under `skills/` with a `SKILL.md` and `agents/openai.yaml`. That folder is the library. The sync skill copies only `skills/` into other projects.

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

Name the skill, or copy/symlink its folder into the project path for the agent you use:

| Agent | Project | Personal |
| --- | --- | --- |
| Cursor | `<that-repo>/.cursor/skills/skill-name/` | `~/.cursor/skills/skill-name/` |
| Claude Code | `<that-repo>/.claude/skills/skill-name/` | `~/.claude/skills/skill-name/` |
| Codex | `<that-repo>/.agents/skills/skill-name/` | `~/.agents/skills/skill-name/` |

Skip `~/.cursor/skills-cursor/`. Cursor keeps its built-in skills there.

User-invoked skills set `disable-model-invocation: true` in `SKILL.md` and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. Codex needs that sidecar. Cursor and Claude Code read the frontmatter.

## Installing the catalog into another project

1. Copy [`sync-rr-skills/`](sync-rr-skills/) into `<that-repo>/.cursor/skills/sync-rr-skills/`. The playbook reads assets from that path.
2. If you run Claude Code, also copy or symlink that folder to `<that-repo>/.claude/skills/sync-rr-skills/`.
3. If you run Codex, also copy or symlink that folder to `<that-repo>/.agents/skills/sync-rr-skills/`.
4. Run the `sync-rr-skills` skill.

That writes `<that-repo>/.agents/skills/radikalreems/` from `skills/` on GitHub, and also `<that-repo>/.claude/skills/radikalreems/` when `.claude/` already exists. Run the skill again to refresh. Opening the project does not sync.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Add `skills/<skill-name>/agents/openai.yaml`.
3. Use lowercase letters, numbers, and hyphens for `<skill-name>`.
4. Follow the frontmatter and authoring rules in [AGENTS.md](AGENTS.md).

Add it to `.cursor/skills/` only if working on this repo should load it.
