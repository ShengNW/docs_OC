#!/usr/bin/env bash
set -euo pipefail

submodule_dir="${PWD}"
parent_dir=""
submodule_path="docs_OC"

submodule_remote="origin"
submodule_branch="main"
expected_submodule_origin="git@github.com:ShengNW/docs_OC.git"
submodule_commit_msg="docs: update docs_OC"

parent_remote="origin"
parent_branch="main"
parent_commit_msg="chore: update docs_OC submodule pointer"

usage() {
  cat <<'USAGE'
Usage:
  push_docs_oc_and_parent.sh [options]

Options:
  --submodule-dir PATH          Path to docs_OC submodule repo (default: current dir)
  --parent-dir PATH             Path to parent repo (default: parent of submodule-dir)
  --submodule-path NAME         Submodule path in parent repo (default: docs_OC)
  --submodule-remote NAME       Submodule remote (default: origin)
  --submodule-branch NAME       Submodule branch (default: main)
  --expected-submodule-origin URL
                                Expected submodule origin URL
                                (default: git@github.com:ShengNW/docs_OC.git)
  --submodule-commit-msg TEXT   Commit message for submodule changes
  --parent-remote NAME          Parent remote (default: origin)
  --parent-branch NAME          Parent branch (default: main)
  --parent-commit-msg TEXT      Commit message for parent pointer update
  --help                        Show this help
USAGE
}

die() {
  echo "[ERROR] $*" >&2
  exit 1
}

log() {
  echo "[INFO] $*"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --submodule-dir)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      submodule_dir="$2"
      shift 2
      ;;
    --parent-dir)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      parent_dir="$2"
      shift 2
      ;;
    --submodule-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      submodule_path="$2"
      shift 2
      ;;
    --submodule-remote)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      submodule_remote="$2"
      shift 2
      ;;
    --submodule-branch)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      submodule_branch="$2"
      shift 2
      ;;
    --expected-submodule-origin)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      expected_submodule_origin="$2"
      shift 2
      ;;
    --submodule-commit-msg)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      submodule_commit_msg="$2"
      shift 2
      ;;
    --parent-remote)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      parent_remote="$2"
      shift 2
      ;;
    --parent-branch)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      parent_branch="$2"
      shift 2
      ;;
    --parent-commit-msg)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      parent_commit_msg="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

submodule_dir="$(cd "$submodule_dir" && pwd)"
if [[ -z "$parent_dir" ]]; then
  parent_dir="$(cd "$submodule_dir/.." && pwd)"
else
  parent_dir="$(cd "$parent_dir" && pwd)"
fi

git -C "$submodule_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Submodule dir is not a git repo: $submodule_dir"
git -C "$parent_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Parent dir is not a git repo: $parent_dir"

submodule_top="$(git -C "$submodule_dir" rev-parse --show-toplevel)"
parent_top="$(git -C "$parent_dir" rev-parse --show-toplevel)"

[[ "$submodule_top" = "$submodule_dir" ]] || die "Run against submodule root. Got $submodule_dir, repo root is $submodule_top"

if [[ ! -e "$parent_top/$submodule_path/.git" && ! -f "$parent_top/$submodule_path/.git" ]]; then
  die "Submodule path '$submodule_path' not found under parent repo: $parent_top"
fi

submodule_current_branch="$(git -C "$submodule_dir" branch --show-current)"
parent_current_branch="$(git -C "$parent_dir" branch --show-current)"

[[ "$submodule_current_branch" = "$submodule_branch" ]] || die "Submodule branch is '$submodule_current_branch', expected '$submodule_branch'"
[[ "$parent_current_branch" = "$parent_branch" ]] || die "Parent branch is '$parent_current_branch', expected '$parent_branch'"

actual_submodule_origin="$(git -C "$submodule_dir" remote get-url "$submodule_remote")"
[[ "$actual_submodule_origin" = "$expected_submodule_origin" ]] || die "Submodule remote '$submodule_remote' is '$actual_submodule_origin', expected '$expected_submodule_origin'"

log "Submodule repo: $submodule_dir"
log "Parent repo: $parent_dir"
log "Pushing submodule to $submodule_remote/$submodule_branch"
log "Pushing parent to $parent_remote/$parent_branch"

if [[ -n "$(git -C "$submodule_dir" status --porcelain)" ]]; then
  log "Committing submodule changes"
  git -C "$submodule_dir" add -A
  git -C "$submodule_dir" commit -m "$submodule_commit_msg"
else
  log "No submodule content changes to commit"
fi

git -C "$submodule_dir" push "$submodule_remote" "$submodule_branch"
submodule_head="$(git -C "$submodule_dir" rev-parse --short HEAD)"

if [[ -n "$(git -C "$parent_dir" diff --cached --name-only)" ]]; then
  die "Parent repo has pre-staged files. Unstage them before running this script."
fi

git -C "$parent_dir" add "$submodule_path"
if git -C "$parent_dir" diff --cached --quiet -- "$submodule_path"; then
  log "No parent pointer update to commit"
else
  log "Committing parent pointer update"
  git -C "$parent_dir" commit -m "$parent_commit_msg"
  git -C "$parent_dir" push "$parent_remote" "$parent_branch"
fi

parent_head="$(git -C "$parent_dir" rev-parse --short HEAD)"

echo
echo "Done."
echo "Submodule HEAD: $submodule_head"
echo "Parent HEAD:    $parent_head"
