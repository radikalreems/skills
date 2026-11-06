---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

A script written to carry out this issue, including a temporary script, goes in the issue project's `scripts/`. Use `.scratch/issues/<issue-slug>/scripts/` for an issue project and `.scratch/features/<issue-slug>/scripts/` for a feature project. A script for the application as a whole, such as a deploy script, goes in the application's `scripts/`.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
