FROM alpine:3.18

# install packages required to run the tests
RUN apk add --no-cache jq curl git

# install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

RUN . "$HOME/.asdf/asdf.sh"

RUN asdf plugin add scarb && asdf install scarb 2.6.5 && asdf global scarb 2.6.5

COPY . /opt/test-runner

WORKDIR /opt/test-runner

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
