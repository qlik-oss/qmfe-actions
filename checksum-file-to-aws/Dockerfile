# Container image that runs your code
FROM amazon/aws-cli:2.4.16


# Copies your code file from your action repository to the filesystem path `/` of the container
COPY checksum-file-to-aws.sh /checksum-file-to-aws.sh

# Code file to execute when the docker container starts up (`checksum-file-to-aws.sh`)
ENTRYPOINT ["/checksum-file-to-aws.sh"]
