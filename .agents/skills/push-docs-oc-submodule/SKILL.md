---
name: push-docs-oc-submodule
description: Execute the Git workflow for docs_OC submodule publishing. Use when the user asks to push changes in docs_OC to git@github.com:ShengNW/docs_OC.git over SSH, then update only the docs_OC submodule pointer in the parent repository and push the parent branch.
---

# Push docs_OC Submodule

## Overview

Use this skill to complete a two-repository publish flow safely:
1. Commit and push the `docs_OC` submodule to `docs_OC.git`.
2. Commit and push only the `docs_OC` submodule pointer update in the parent repository.

Prefer the bundled script for repeatable execution; use the manual workflow for debugging.

## Required Inputs

Collect these values before running:
- Submodule repo path (default: current directory)
- Parent repo path (default: one level up)
- Branch names (default: `main` in both repos)
- Commit messages for submodule content and parent pointer update

## Fast Path (Script)

Run:

```bash
.agents/skills/push-docs-oc-submodule/scripts/push_docs_oc_and_parent.sh \
  --submodule-dir /absolute/path/to/docs_OC \
  --parent-dir /absolute/path/to/SnwHist \
  --submodule-commit-msg "docs: update codex content" \
  --parent-commit-msg "chore: update docs_OC submodule pointer"
```

Script behavior:
- Verify submodule `origin` URL is exactly `git@github.com:ShengNW/docs_OC.git`
- Commit submodule changes if needed, then push submodule branch
- Stage only `docs_OC` in parent repo, commit pointer update if changed, then push parent branch
- Refuse to continue if unrelated parent files are already staged

## Manual Workflow

1. In submodule repository:
   - Run `git status --short --branch`
   - Run `git remote -v` and confirm SSH URL for `origin`
   - Run `git add -A`
   - Run `git commit -m "<submodule message>"` (skip if no changes)
   - Run `git push origin <submodule-branch>`
2. In parent repository:
   - Run `git add docs_OC`
   - Run `git diff --cached --name-only` and ensure only `docs_OC` is staged
   - Run `git commit -m "<parent pointer message>"` (skip if no pointer change)
   - Run `git push origin <parent-branch>`
3. Report both commit SHAs and final `git status --short --branch` for both repositories.

## Guardrails

- Push `docs_OC` using SSH remote URL only.
- Stage and commit only `docs_OC` in parent repository.
- Stop and ask before switching branches.
- Avoid destructive Git commands unless the user explicitly asks.

## References

Read `references/workflow.md` for command variants and troubleshooting.
