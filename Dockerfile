ARG ARCH=arm32v7
FROM ${ARCH}/debian

# Install dependencies
RUN apt-get update && \
    apt-get -y install gnupg1 apt-transport-https dirmngr curl jq

# Install speedtest cli
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61 && \
    echo "deb https://ookla.bintray.com/debian buster main" | tee /etc/apt/sources.list.d/speedtest.list && \
    apt-get update && \
    apt-get -y install speedtest

COPY ./speedtest.sh .
CMD ["./speedtest.sh"]
