# Bldr

![The Boulder](res/thebldr.jpg "The Boulder")

Perform RPM builds using a templated RPM specfile.

Given a specfile and value file, `bldr` will facilitate rendering the specfile and performing an RPM build. This utility is distributed as a container image
`jharshman/bldr`.

Usage requires composing your own Dockerfile based on `jharshman/bldr:latest`.
You can install additional software needed by the rpmbuild such as Golang.

```Dockerfile
FROM --platform=arm64 jharshman/bldr:latest

RUN zypper in -y wget

RUN wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin
```
