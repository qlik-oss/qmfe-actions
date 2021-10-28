# Container image that runs your code
FROM amazon/aws-cli:2.3.0

# add jq to image
RUN yum update -y \
    && yum install -y gcc-c++ make jq
# add node to image
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -
RUN yum install -y nodejs

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY import-map-to-aws.sh /import-map-to-aws.sh
COPY translate-import-map-to-metrics.js /translate-import-map-to-metrics.js

# Code file to execute when the docker container starts up (`import-map-to-aws.sh`)
ENTRYPOINT ["/import-map-to-aws.sh"]
