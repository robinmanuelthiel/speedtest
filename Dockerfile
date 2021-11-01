ARG ARCH=arm32v7
FROM ${ARCH}/debian

# Install dependencies
RUN apt-get update && \
    apt-get -y install gnupg1 apt-transport-https dirmngr curl jq

# Install speedtest cli
RUN curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash && \
    apt-get install speedtest

COPY ./speedtest.sh .
CMD ["./speedtest.sh"]
