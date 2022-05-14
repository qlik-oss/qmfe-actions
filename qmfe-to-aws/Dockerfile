# Container image that runs your code
FROM amazon/aws-cli:2.7.0


# Copies your code file from your action repository to the filesystem path `/` of the container
COPY qmfe-to-aws.sh /qmfe-to-aws.sh

# Code file to execute when the docker container starts up (`qmfe-to-aws.sh`)
ENTRYPOINT ["/qmfe-to-aws.sh"]
