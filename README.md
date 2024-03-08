# Bldr

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

There are a few directories you're going to want to mount to the running container.

- `SOURCES/` is mounted to the rpmbuild tree. This is where you would drop a tarball of the source code you want to build.
- `RPMS/` is mounted to the rpmbuild tree. This is where the resulting RPM will be dropped after a successful build.

```bash
docker build -f Dockerfile-rpmbuild -t hello-release:latest .
docker run \
    --rm \
    -v $(PWD)/test:/root/test \
    -v $(PWD)/SOURCES:/root/rpmbuild/SOURCES \
    -v $(PWD)/RPMS:/root/rpmbuild/RPMS \
    hello-release:latest \
    --spec-file /root/test/example.spec \
    --value-file /root/test/values.yaml \
    ;
```
