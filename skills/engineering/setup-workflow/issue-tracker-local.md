# Issue tracker: Local Markdown

The local issue tracker is `.scratch/issues/`. `.scratch/features/` uses this same layout for work a human handles. Paths below use `.scratch/issues/`. For human-handled work, use `.scratch/features/` in place of `.scratch/issues/`.

An issue project is one folder under `.scratch/issues/`. It may contain any of the files below.

```
.scratch/issues/
├── BACKLOG.md
├── _done/
│   └── <issue-slug>/
└── <issue-slug>/
    ├── issue.md
    ├── spec.md
    ├── map.md
    ├── research/
    └── tasks/
        ├── <NN>-<slug>.md
        └── _done/
```

- `BACKLOG.md` is a dump of issues that have not been looked at yet. An entry can be small or large. Text here stays a dump. Create an issue-project folder when the user asks to take an entry out of the backlog.
- `_done/` holds issue projects that are finished. Move the project folder here when the work is done. It is not an issue project of its own. Skip it when scanning for open work.
- `issue.md` is the raw report, usually pasted from a user who wants the problem filed without a designed spec. Scope lives in `spec.md`.
- `spec.md` says what the issue is, what is in scope, and what is out of scope. `/to-spec` builds it. When `map.md` is present, the spec is based on that map.
- `map.md` is present when `/wayfinder` made this issue project a map. It holds Destination, Notes, Decisions-so-far, Not yet specified, and Out of scope.
- `research/` holds temporary files from research run while deciding the solution. Write a findings file here when a research ticket names this folder. The folder gets large. Read a file in it only when the user, a ticket, or the map names that file.
- `tasks/` is one file per ticket, usually from `/to-tickets`. Name each file `<NN>-<slug>.md`, numbered from `01` in dependency order, blockers first. When a ticket is done, move that file into `tasks/_done/`.

When an issue or ticket contains a checklist, change each finished item from `- [ ]` to `- [x]` and save the file before continuing.

Record triage state as a `Status:` line near the top of the file. Role strings are in `triage-labels.md`. Append comments under a `## Comments` heading at the bottom of the file.

## Wayfinding operations

Used by `/wayfinder`. The map is one file. Each decision ticket is its own file under `tasks/`.

- **Map**: `.scratch/issues/<effort>/map.md`.
- **Child ticket**: `.scratch/issues/<effort>/tasks/<NN>-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records `research`, `prototype`, `grilling`, or `task`. A `Status:` line records `claimed` or `resolved`.
- **Research findings**: one file in `.scratch/issues/<effort>/research/`. The ticket points at that file.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan ticket files directly in `.scratch/issues/<effort>/tasks/`, skipping `_done/`, for files that are open, unblocked, and unclaimed. First by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, move the file into `tasks/_done/`, then append a context pointer, gist and link, to Decisions-so-far in `map.md`.
