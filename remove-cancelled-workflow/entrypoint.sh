#!/bin/bash
set -e

if [ -z "$REPOSITORY" ]; then
  echo "REPOSITORY is not set"
  exit 1
fi

if [ -z "$WORKFLOW_NAME" ]; then
  echo "WORKFLOW_NAME is not set"
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN is not set"
  exit 1
fi

echo "Running clean-up-cancelled with the following environment variables:"
echo "REPOSITORY:         $REPOSITORY"
echo "WORKFLOW_NAME:      $WORKFLOW_NAME"
echo "GITHUB_TOKEN        $GITHUB_TOKEN"
echo ""

function clean_up_cancelled() {

    local -r repository_url="https://api.github.com/repos/$REPOSITORY/"
    local -r workflow_url="${repository_url}actions/workflows/$WORKFLOW_NAME.yaml/runs?status=cancelled\&per_page=1"
    local -r header_auth="Authorization: token $GITHUB_TOKEN"
    local -r header_accept="application/vnd.github.v3+json"

    echo "Calling $workflow_url"

    # Get cancelled system test workflow run
    run_id=$(curl -H "$header_auth" -H "$header_accept" "$workflow_url" | jq '.workflow_runs[].id')

    echo "run_id=$run_id"
    # Delete cancelled run
    if [ -n "$run_id" ]; then
        curl -X DELETE -H "$header_auth" -H "$header_accept" "${repository_url}actions/runs/$run_id"
        echo "WORKFLOW RUN => $run_id was deleted"
    fi
}

clean_up_cancelled "$@"
