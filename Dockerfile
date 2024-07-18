FROM alpine:3.18

# install packages required to run the tests
RUN apk add --no-cache jq curl git

# install Scarb
RUN curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v 2.6.5

COPY . /opt/test-runner

WORKDIR /opt/test-runner

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
