# Container image that runs your code
FROM amazon/aws-cli:2.3.6

# add jq to image
RUN yum update -y \
    && yum install -y gcc-c++ make jq wget
# add node to image
RUN wget https://rpm.nodesource.com/pub_14.x/el/7/x86_64/nodejs-14.18.1-1nodesource.x86_64.rpm
RUN yum install -y nodejs-14.18.1-1nodesource.x86_64.rpm

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY import-map-to-aws.sh /import-map-to-aws.sh
COPY translate-import-map-to-metrics.js /translate-import-map-to-metrics.js

# Code file to execute when the docker container starts up (`import-map-to-aws.sh`)
ENTRYPOINT ["/import-map-to-aws.sh"]
