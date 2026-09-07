# Out-of-scope knowledge base

The `.out-of-scope/` directory in a repo stores persistent records of rejected feature requests. It serves two purposes:

1. **Institutional memory.** Why a feature was rejected, so the reasoning isn't lost when the issue is closed.
2. **Deduplication.** When a new issue matches a prior rejection, the skill can surface the previous decision instead of re-litigating it.

## Directory structure

One file per concept, not per issue. Multiple issues requesting the same thing share one file.

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

## File format

Write each file as a short design document, not a database entry. Use paragraphs, code samples, and examples so the reasoning is clear to someone seeing it for the first time.

```markdown
# Dark mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette in `ThemeConfig`.
Supporting multiple themes would require a theme context, per-component
style resolution, and preference persistence. That change does not match
this project's focus on content authoring.
```

## Process

### Naming the file

Use a short, descriptive kebab-case name for the concept: `dark-mode.md`, `plugin-system.md`, `graphql-api.md`. Someone browsing the directory should recognize what was rejected without opening the file.

### Writing the reason

The reason should be substantive. Not "we don't want this" but why. Good reasons reference:

- Project scope or philosophy ("This project focuses on X; theming is a downstream concern")
- Technical constraints ("Supporting this would require Y, which conflicts with our Z architecture")
- Strategic decisions ("We chose to use A instead of B because...")

Write a durable reason. Temporary circumstances like being too busy are deferrals, not rejections.

### When to check `.out-of-scope/`

During triage (Step 1: Gather context), read all files in `.out-of-scope/`. When evaluating a new issue:

- Check if the request matches an existing out-of-scope concept
- Matching is by concept similarity, not keyword: "night theme" matches `dark-mode.md`
- If there's a match, surface it to the maintainer: "This is similar to `.out-of-scope/dark-mode.md`. We rejected this before because [reason]. Do you still feel the same way?"

The maintainer may:

- **Confirm.** Add a line that names the new issue to the existing file, then close it.
- **Reconsider.** Delete or update the out-of-scope file. The issue proceeds through normal triage.
- **Disagree.** The issues are related but distinct. Proceed with normal triage.

### When to write to `.out-of-scope/`

Write here only when an enhancement is rejected as `wontfix`. This applies to enhancement PRs the same way it applies to issues: a rejected PR is recorded here so the same request doesn't return as fresh code.

A close as `wontfix` because the feature is already implemented is not a rejection. Point the closing comment at where the feature lives.

The flow:

1. Maintainer decides a feature request is out of scope
2. Check if a matching `.out-of-scope/` file already exists
3. If yes: add a line that names the new issue
4. If no: create a file with the concept name, the decision, and the reason
5. Post a comment on the issue explaining the decision and mentioning the `.out-of-scope/` file
6. Close the issue with the `wontfix` label

### Updating or removing out-of-scope files

If the maintainer changes their mind about a previously rejected concept:

- Delete the `.out-of-scope/` file
- The skill does not need to reopen old issues; they're historical records
- The new issue that triggered the reconsideration proceeds through normal triage
