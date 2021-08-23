# Container image that runs your code
FROM amazon/aws-cli:2.2.29

# add jq to image
RUN yum install jq -y
# add node to image
RUN yum install nodejs14 -y

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
COPY translate-import-map-to-metrics.js /translate-import-map-to-metrics.js

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
