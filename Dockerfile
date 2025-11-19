FROM ubuntu:22.04

RUN apt update && apt install -y git build-essential apt-utils cmake libfontconfig1 libfontconfig1-dev libglib2.0-dev libtinfo5 python3 python3-pip golang-go

WORKDIR /havoc
RUN git clone https://github.com/HavocFramework/Havoc.git . && \
    git submodule update --init --recursive && \
    cd teamserver && go mod download golang.org/x/sys && go build && cd .. && \
    make build

EXPOSE 40056

CMD ["./havoc", "server", "--profile", "./profiles/havoc.yaotl", "-v"]