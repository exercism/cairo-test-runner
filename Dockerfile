# target = alpine-latest
FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS builder

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

FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS runner

# install jq package to format test results
RUN apk add --no-cache jq

COPY --from=builder /opt/test-runner/bin/scarb /opt/test-runner/bin/scarb
ENV PATH=$PATH:/opt/test-runner/bin/scarb/bin

WORKDIR /opt/test-runner

COPY bin/run.sh bin/run.sh

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
