FROM --platform=arm64 jharshman/bldr:latest

RUN zypper in -y wget

RUN wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin
