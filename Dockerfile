ARG REPO=alpine
ARG IMAGE=3.20.0@sha256:77726ef6b57ddf65bb551896826ec38bc3e53f75cdde31354fbffb4f25238ebd
FROM ${REPO}:${IMAGE} AS builder

# set up Scarb
ARG VERSION=v2.12.0
ARG RELEASE=scarb-${VERSION}-x86_64-unknown-linux-musl

WORKDIR /opt/test-runner/bin/scarb
ADD https://github.com/software-mansion/scarb/releases/download/${VERSION}/${RELEASE}.tar.gz .
RUN tar -xf ${RELEASE}.tar.gz --strip-components=1 \
    && rm -rf ./doc \
    ./bin/scarb-cairo-language-server \
    ./bin/scarb-cairo-run \
    ./bin/scarb-snforge-test-collector

FROM ${REPO}:${IMAGE} AS runner

# install jq package to format test results
RUN apk add --no-cache jq

COPY --from=builder /opt/test-runner/bin/scarb /opt/test-runner/bin/scarb
ENV PATH=$PATH:/opt/test-runner/bin/scarb/bin

WORKDIR /opt/test-runner

COPY bin/run.sh bin/run.sh

# Initialize a Cairo cache
RUN mkdir -p init-cairo-cache/src
COPY Scarb.toml init-cairo-cache/
RUN echo '// dummy file' > init-cairo-cache/src/lib.cairo \
    && scarb --manifest-path init-cairo-cache/Scarb.toml --release build \
    && rm -rf init-cairo-cache/

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
