# Container image that runs your code
FROM amazon/aws-cli:2.2.9

LABEL repository="http://github.com/qlik-oss/qmfe-actions"
LABEL homepage="http://github.com/qlik-oss/qmfe-actions/qmfe-to-aws"
LABEL "com.github.actions.name"="qmfe-to-aws"
LABEL "com.github.actions.description"="Uploads a qmfe package to a AWS S3 bucket"
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="green"

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
