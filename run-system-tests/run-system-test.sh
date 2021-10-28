#!/bin/bash

err_report() {
  echo "Error on line $1"
}

trap 'err_report $LINENO' ERR

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
  echo "SUITE is not set, defaulting to qmfe"
  export SUITE=qmfe
fi

if [ -z "$QMFE_OVERRIDE" ]; then
  echo "QMFE_OVERRIDE is not set, tests will run without any overrides"
fi

echo "import-map overrides that will be used in test run: $QMFE_OVERRIDE"

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

# Download image, start and run test container
docker-compose -f "$GITHUB_ACTION_PATH"/docker-compose.yml up --exit-code-from sut
