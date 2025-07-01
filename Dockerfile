FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive 

# Basic setup
RUN apt-get update && \
    apt-get install -y software-properties-common curl zip jq

# Copy entrypoint
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]