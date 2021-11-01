ARG ARCH=
FROM ${ARCH}debian

# Install basics
RUN apt-get update
RUN apt-get -y install curl

# Install speedtest cli
RUN curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash && \
    apt-get install speedtest

COPY ./speedtest.sh .
CMD ["./speedtest.sh"]
