#!/bin/bash

set -e

if [ -z "$SOURCE_BRANCH" ]; then
  echo "SOURCE_BRANCH is not set"
  exit 1
fi

if [ -z "$TARGET_BRANCH" ]; then
  echo "TARGET_BRANCH is not set"
  exit 1
fi

if [ -z "$FF_ONLY" ]; then
  FF_ONLY="false"
fi

echo "Running merge-branch with the following environment variables:"
echo "SOURCE_BRANCH = '$SOURCE_BRANCH'"
echo "TARGET_BRANCH = '$TARGET_BRANCH'"
echo "FF_ONLY = $FF_ONLY"
echo

function merge_branch() {

  FF_MODE="--no-ff"
  if [[ "$FF_ONLY" == "true" ]]; then
    FF_MODE="--ff-only"
  fi

  git remote set-url origin "https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"

  git config --global user.name "$GITHUB_ACTOR"
  git config --global user.email "$GITHUB_ACTOR@github.com"

  set -o xtrace

  git fetch origin "$SOURCE_BRANCH"
  git checkout "$SOURCE_BRANCH"
  git pull --rebase

  local -r last_commit_msg="$(git show -s --format=%s)"
  echo "last commit message is: $last_commit_msg"

  git fetch origin "$TARGET_BRANCH"
  git checkout "$TARGET_BRANCH"
  git pull --rebase

  set +o xtrace
  echo
  echo "will merge $SOURCE_BRANCH ($(git log -1 --pretty=%H "$SOURCE_BRANCH"))"
  echo "into $TARGET_BRANCH ($(git log -1 --pretty=%H "$TARGET_BRANCH"))"
  echo
  set -o xtrace

  # Do the merge
  git merge $FF_MODE "$SOURCE_BRANCH" -m "[AUTO MERGE]: $last_commit_msg"

  # Push the branch
  git push origin "$TARGET_BRANCH"
}

merge_branch "$@"
