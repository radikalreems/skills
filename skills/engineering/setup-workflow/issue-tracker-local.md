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
    ├── tickets/
    │   ├── <NN>-<slug>.md
    │   └── _done/
    ├── seams/
    │   ├── <repo-slug>.md
    │   └── _done/
    └── tasks/
        ├── <NN>-<slug>.md
        └── _done/
```

- `BACKLOG.md` is a dump of issues that have not been looked at yet. An entry can be small or large. Text here stays a dump. Create an issue-project folder when the user asks to take an entry out of the backlog.
- `_done/` holds issue projects that are finished. Move the project folder here when the work is done and no seam file is left directly in `seams/`. It is not an issue project of its own. Skip it when scanning for open work.
- `issue.md` is the raw report, usually pasted from a user who wants the problem filed without a designed spec. Scope lives in `spec.md`.
- `spec.md` says what the issue is, what is in scope, and what is out of scope. `/to-spec` builds it. When `map.md` is present, the spec is based on that map.
- `map.md` is present when `/wayfinder` made this issue project a map. It holds Destination, Notes, Decisions-so-far, Not yet specified, and Out of scope.
- `research/` holds temporary files from research run while deciding the solution. Write a findings file here when a research task names this folder. The folder gets large. Read a file in it only when the user, a task, or the map names that file.
- `tickets/` is one file per ticket, usually from `/to-tickets`. A ticket is a code implementation action. Name each file `<NN>-<slug>.md`, numbered from `01` in dependency order, blockers first. When a ticket is done, move that file into `tickets/_done/`.
- `seams/` is one file per other repo, from `/to-seam`. A seam is how that repo connects to a surface this repo has already built. Name the file `<repo-slug>.md`. Seam operations say when it moves to `seams/_done/`.
- `tasks/` is one file per task, from `/wayfinder`. A task is a wayfinding map action. Name each file `<NN>-<slug>.md`, numbered from `01`. When a task is done, move that file into `tasks/_done/`.

When an issue, ticket, or task contains a checklist, change each finished item from `- [ ]` to `- [x]` and save the file before continuing.

Record triage state as a `Status:` line near the top of the file. Role strings are in `triage-labels.md`. Append comments under a `## Comments` heading at the bottom of the file.

## Seam operations

This repo writes the seam and moves it. The other repo writes its slug onto the seam, and a `Seam:` line on its own issue project.

- **File**: `.scratch/issues/<effort>/seams/<repo-slug>.md`, from `/to-seam`. `Repo:` is the path from this repo to the other repo's root. `Issue project:` is the slug. `/to-seam` leaves `Issue project:` blank.
- **Open**: the other repo creates its issue project, writes the slug on that `Issue project:` line, and writes this file's path as a `Seam:` line at the top of its `issue.md`. Create `issue.md` when that project has none, with the `Seam:` line as its contents.
- **Done**: move the seam file into `seams/_done/` when `<repo>/.scratch/issues/_done/<slug>/` or `<repo>/.scratch/features/_done/<slug>/` is the only folder with that slug. Leave the slug as first written. A blank `Issue project:` stays in `seams/`.
- **Remove**: delete the seam file when that repo will not have an issue project.
- **Cycle**: when two projects name each other, ask the user which seam to remove before moving either project to `_done/`.

## Wayfinding operations

Used by `/wayfinder`. The map is one file. Each task is its own file under `tasks/`.

- **Map**: `.scratch/issues/<effort>/map.md`.
- **Child task**: `.scratch/issues/<effort>/tasks/<NN>-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records `research`, `prototype`, `grilling`, or `task`. A `Status:` line records `claimed` or `resolved`.
- **Research findings**: one file in `.scratch/issues/<effort>/research/`. The task points at that file.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A task is unblocked when every file it lists is `resolved`.
- **Frontier**: scan task files directly in `.scratch/issues/<effort>/tasks/`, skipping `_done/`, for files that are open, unblocked, and unclaimed. First by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, move the file into `tasks/_done/`, then append a context pointer, gist and link, to Decisions-so-far in `map.md`.
