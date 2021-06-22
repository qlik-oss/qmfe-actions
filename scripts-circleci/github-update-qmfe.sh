#!/usr/bin/env bash

# This script is based on the wonderful work by the pipeline team:
# https://raw.githubusercontent.com/qlik-oss/ci-tools/master/scripts-circleci/github-package-helm-dispatch.sh

VERSION_FILE=${VERSION_FILE:="/workspace/version.txt"}
GITHUB_WORKFLOW=${GITHUB_WORKFLOW:="qmfe.yaml"}

if [ -n "${CIRCLE_TAG}" ]; then
  REF=${CIRCLE_TAG}

  if [ -z "${VERSION}" ]; then
    VERSION=$(cat "$VERSION_FILE")
  fi

  # Final check that version is set
  if [ -z "${VERSION}" ]; then
    echo "ERROR: VERSION could not be determined"
    echo "If version file is in different location than ${VERSION_FILE}"
    echo "before running this script, set a variable:"
    echo "export VERSION_FILE=/path/version.txt"
    echo "or set VERSION variable directly'"
    echo 'export VERSION="$(node|cat ...)"'
    exit 1
  fi

  body_template='{"ref":"%s","inputs":{"version":"%s"}}'
  body=$(printf $body_template "$REF" "$VERSION")
  echo "Using ${body}"

  curl --fail --location --request POST "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/actions/workflows/${GITHUB_WORKFLOW}/dispatches" \
    --header "Authorization: token ${GH_ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --header "Accept: application/vnd.github.v3+json" \
    --data "${body}"
else
  echo "Skipping for non-tagged builds"
fi
