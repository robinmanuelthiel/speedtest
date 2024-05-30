FROM debian:bullseye

# Install basics
RUN apt-get update && apt-get install -y curl jq gnupg1 apt-transport-https dirmngr

# Install speedtest cli
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
RUN apt-get install -y speedtest

COPY ./speedtest.sh .
CMD ["./speedtest.sh"]
