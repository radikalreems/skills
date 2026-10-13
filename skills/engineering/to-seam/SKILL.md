---
name: to-seam
description: Write a seam file another repo uses to connect to a surface this repo has already built.
disable-model-invocation: true
---

# To Seam

A **seam** is a file another repo uses to connect to a surface this repo has already built. One file per other repo, under that issue project's `seams/`.

The file states the **exchange**: the names, shapes, failures, and ids that surface already exposes. The other repo opens its own issue project to build against that exchange.

## Process

### 1. Name the project and the repos

Get the issue-project folder, and for each other repo its slug and the path from this repo to that repo's root, for example `../frontend`. Ask for any of these you do not already have.

One seam per repo. The filename is that repo's slug.

Done when you have the issue-project folder and, for each repo, a slug and a root path.

### 2. Read the surface

Read the code that forms the exchange. Read the issue project's spec and tickets so you know which surface they mean. Where the spec and the code disagree, write what the code does.

When that exchange is not in the code yet, stop and name what is missing. A seam describes a surface that already exists.

Done when every fact you will put in the seam is visible in this repo's code.

### 3. Draft and check

Draft one file per repo in the shape below. Leave **Issue project** blank. The other repo writes its issue-project slug there when it opens that project.

Keep a sentence when it names a fact this repo's code settles and it stays true however the other repo lays out its buttons. Drop the rest.

Show the drafts and wait until the user accepts them.

### 4. Write

Write each accepted file to `<issue-project>/seams/<repo-slug>.md`. Create `seams/` when it is absent. An issue project lives at `.scratch/issues/<slug>/`. A feature project lives at `.scratch/features/<slug>/`.

Done when each file is on disk and **Issue project** is empty.

## Shape

```markdown
# Seam: <repo name>

**Repo:** <path from this repo to that repo's root>
**Issue project:**

## Exchange

<Facts this repo's code already settles. Routes, fields, status codes, error bodies, and ids that must round-trip. Inline a type or payload shape when that shape is the exchange.>
```
