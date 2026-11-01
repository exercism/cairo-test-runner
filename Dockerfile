# target = alpine-latest
FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS builder

# set up Scarb
ARG VERSION=v2.14.0
ARG RELEASE=scarb-${VERSION}-x86_64-unknown-linux-musl

WORKDIR /opt/test-runner/bin/scarb
ADD https://github.com/software-mansion/scarb/releases/download/${VERSION}/${RELEASE}.tar.gz .
RUN tar -xf ${RELEASE}.tar.gz --strip-components=1 \
    && rm -rf ./doc \
    ./bin/scarb-cairo-language-server \
    ./bin/scarb-cairo-run \
    ./bin/scarb-snforge-test-collector

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS runner

# install jq package to format test results
RUN apk add --no-cache jq

COPY --from=builder /opt/test-runner/bin/scarb /opt/test-runner/bin/scarb
ENV PATH=$PATH:/opt/test-runner/bin/scarb/bin

WORKDIR /opt/test-runner

COPY bin/run.sh bin/run.sh

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
