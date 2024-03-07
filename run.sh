#!/bin/bash

# package the source code into a tarball
tar -czv --exclude-vcs --strip-components=2 -f SOURCES/hello-v1.0.0.tar.gz ./test/hello/*

# run the bldr
docker run \
    --rm \
    -v $(PWD)/test:/root/test \
    -v $(PWD)/SOURCES:/root/rpmbuild/SOURCES \
    bldr:latest \
    --spec-file /root/test/example.spec \
    --value-file /root/test/values.yaml \
    ;
