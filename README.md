# Bldr

![The Boulder](res/thebldr.png "The Boulder")

### Summary

Bldr (Pronounced Boulder) performs RPM builds using a templated RPM specfile.

Given a specfile and value file, `bldr` will facilitate rendering the specfile and performing an RPM build. This utility is distributed as a container image
`jharshman/bldr`.

While not required, it is reccomended to composing your own Dockerfile based on `jharshman/bldr:latest`. This Dockerfile will serve as the sterile environment in which you build your RPM. Here you can install whatever software is required for your build. In the past this was done by way of Chroot Jails, but I find it more user friendly to use Docker for this instead.

Here is the Dockerfile used for building the small Go project in the `examples` directory.

```Dockerfile
FROM --platform=arm64 jharshman/bldr:latest

RUN zypper in -y wget

RUN wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin
```
