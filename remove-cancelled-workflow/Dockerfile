# Container image that runs your code
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    curl \
    jq

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY removed-cancelled-workflow.sh /removed-cancelled-workflow.sh

# Code file to execute when the docker container starts up (`removed-cancelled-workflow.sh`)
ENTRYPOINT ["/removed-cancelled-workflow.sh"]
