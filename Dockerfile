FROM alpine:3.18 AS builder

# set up Scarb
ARG VERSION=v2.6.5
ARG RELEASE=scarb-${VERSION}-x86_64-unknown-linux-musl

WORKDIR /opt/test-runner/bin/scarb
ADD https://github.com/software-mansion/scarb/releases/download/${VERSION}/${RELEASE}.tar.gz .
RUN tar -xf ${RELEASE}.tar.gz --strip-components=1 \
    && rm -rf ./doc \
    && rm -rf ./bin/scarb-cairo-language-server \
    && rm -rf ./bin/scarb-cairo-run \
    && rm -rf ./bin/scarb-snforge-test-collector

ENV PATH=$PATH:/opt/test-runner/bin/scarb/bin

# install jq package to format test results
RUN apk add --no-cache jq

WORKDIR /opt/test-runner

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
