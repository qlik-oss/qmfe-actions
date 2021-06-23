# Container image that runs your code
FROM ubuntu:latest

LABEL repository="http://github.com/qlik-oss/qmfe-actions"
LABEL homepage="http://github.com/qlik-oss/qmfe-actions/remove-cancelled-workflow"
LABEL "com.github.actions.name"="remove-cancelled-workflow"
LABEL "com.github.actions.description"="Removes previously cancelled workflows"
LABEL "com.github.actions.icon"="delete"
LABEL "com.github.actions.color"="red"

RUN apt-get update && apt-get install -y \
    curl \
    jq

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
