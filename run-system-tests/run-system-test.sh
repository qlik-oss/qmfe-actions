#!/bin/bash

#set eo pipefail

if [ -z "$IMAGE" ]; then
  echo "Docker image is not set"
  exit 1
fi

if [ -z "$DOCKER_USERNAME" ]; then
  echo "DOCKER_USERNAME is not set"
  exit 1
fi

if [ -z "$DOCKER_PWD" ]; then
  echo "DOCKER_PWD is not set"
  exit 1
fi

if [ -z "$WDURL" ]; then
  echo "URL to zalenium grid is not set, no grid will be used for test run"
fi

if [ -z "$BASEURL" ]; then
  echo "BASEURL is not set"
  exit 1
fi

if [ -z "$SUITE" ]; then
  echo "SUITE is not set defaulting to qmfe"
  export SUITE=qmfe
fi

if [ -z "$QMFE_OVERRIDE" ]; then
  echo "QMFE_OVERRIDE is not set, tests will run without any overrides"
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN is not set"
  exit 1
fi

echo "Running system-tests with the following environment variables:"
echo "DOCKER_IMAGE:       $DOCKER_IMAGE"
echo "DOCKER_USERNAME:    $DOCKER_USERNAME"
echo "DOCKER_PWD:         $DOCKER_PWD"
echo "WDURL:              $WDURL"
echo "SUITE:              $SUITE"
echo "QMFE_OVERRIDE:      $QMFE_OVERRIDE"
echo "GITHUB_TOKEN:        $GITHUB_TOKEN"
echo ""

function run_tests() {
  echo "import-map that will be used in test run: $QMFE_OVERRIDE"

  # Check if QMFE_OVERRIDE is path to import-map
  if [[ "$QMFE_OVERRIDE" = http* ]]; then
    QMFE_OVERRIDE=$(curl "$QMFE_OVERRIDE" | jq --raw-output '.imports | tojson')
  elif [[ -f "$QMFE_OVERRIDE" ]]; then
    QMFE_OVERRIDE=$(jq --raw-output '.imports | tojson' "$QMFE_OVERRIDE")
  fi

  # Login to docker registry
  REGISTRY_ORG=$(echo "$IMAGE" | sed 's|\(.*\)/.*|\1|')
  echo "Logging into docker registry..."
  echo "$DOCKER_PWD" | docker login -u "$DOCKER_USERNAME" --password-stdin "$REGISTRY_ORG"
  
  # Start test-run
  docker-compose -f run-system-tests/docker-compose.yml up --exit-code-from sut
}
run_tests "$@"