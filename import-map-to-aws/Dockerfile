# Container image that runs your code
FROM amazon/aws-cli:2.2.40

# add jq to image
RUN yum update -y \
    && yum install -y gcc-c++ make jq
# add node to image
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -
RUN yum install -y nodejs

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
COPY translate-import-map-to-metrics.js /translate-import-map-to-metrics.js

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
