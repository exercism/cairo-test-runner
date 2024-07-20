ARG REPO=alpine
ARG IMAGE=3.18
FROM ${REPO}:${IMAGE} AS builder

ARG VERSION=v2.6.5
ARG RELEASE=scarb-${VERSION}-x86_64-unknown-linux-musl

RUN apk add --no-cache curl

RUN mkdir opt/test-runner
RUN mkdir opt/test-runner/bin
WORKDIR /tmp
ADD https://github.com/software-mansion/scarb/releases/download/${VERSION}/${RELEASE}.tar.gz .
RUN tar -xf ${RELEASE}.tar.gz \
    && rm -rf /tmp/${RELEASE}/doc \
    && mv /tmp/${RELEASE} /opt/test-runner/bin/scarb

FROM ${REPO}:${IMAGE} AS runner

# install packages required to run the tests
# hadolint ignore=DL3018
RUN apk add --no-cache jq

COPY --from=builder /opt/test-runner/bin/scarb /opt/test-runner/bin/scarb
ENV PATH=$PATH:/opt/test-runner/bin/scarb/bin

WORKDIR /opt/test-runner
COPY . .
# Initialize a scarb cache
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
