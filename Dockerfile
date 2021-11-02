FROM debian:bullseye

# Install basics
RUN apt-get update && apt-get install -y curl jq

# Install speedtest cli
RUN curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash
RUN apt-get install speedtest

COPY ./speedtest.sh .
CMD ["./speedtest.sh"]
