# docs_OC Push Workflow Reference

## Standard Sequence

1. Work in submodule repository (`docs_OC`):
   - `git status --short --branch`
   - `git remote -v` (confirm `origin` is `git@github.com:ShengNW/docs_OC.git`)
   - `git add -A`
   - `git commit -m "<submodule message>"` (skip if clean)
   - `git push origin main`
2. Move to parent repository (`SnwHist`):
   - `git add docs_OC`
   - `git diff --cached --name-only` (must show only `docs_OC`)
   - `git commit -m "<pointer message>"` (skip if no pointer change)
   - `git push origin main`
3. Verify both repositories:
   - `git -C /path/to/docs_OC status --short --branch`
   - `git -C /path/to/SnwHist status --short --branch`

## Recommended Commit Message Pattern

- Submodule: `docs: <what changed in docs_OC>`
- Parent: `chore: update docs_OC submodule pointer`

## Common Failures

- `non-fast-forward` on push: run `git pull --rebase`, resolve conflicts, retry push.
- Remote URL mismatch: set SSH remote with `git remote set-url origin git@github.com:ShengNW/docs_OC.git`.
- Parent contains staged files: unstage unrelated files before committing pointer update.
