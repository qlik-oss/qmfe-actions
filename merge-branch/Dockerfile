
FROM ubuntu:latest

LABEL repository="http://github.com/qlik-oss/qmfe-actions"
LABEL homepage="http://github.com/qlik-oss/qmfe-actions/merge-branch"
LABEL "com.github.actions.name"="merge-branch"
LABEL "com.github.actions.description"="Merges source branch to target branch."
LABEL "com.github.actions.icon"="git-merge"
LABEL "com.github.actions.color"="green"

RUN apk --no-cache add bash curl git git-lfs jq

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
