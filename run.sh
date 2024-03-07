#!/bin/bash

usage() {
    cat <<EOM
Usage: $0 [options]

Options:
    --source_dir    Path to source code to build
    --semver        Version to publish as
    --help          Display usage

Example:
    $0 --source_dir ./Projects/fwsync --semver v2.0.0
EOM
}

main() {
    local _source_dir
    local _semver

    while (( $# )); do
        case "$1" in
        --source-dir)
            _source_dir=$2
            shift 2
            ;;
        --semver)
            _semver=$2
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
        esac
    done

    pushd $_source_dir/.. > /dev/null
    tar -czv --exclude-vcs -f $(basename $_source_dir).tar.gz $(basename $_source_dir)
    popd > /dev/null
    mv $_source_dir/../$(basename $_source_dir).tar.gz SOURCES/

    # run the bldr
    docker run \
        --rm \
        -v $(PWD)/test:/root/test \
        -v $(PWD)/SOURCES:/root/rpmbuild/SOURCES \
        -v $(PWD)/RPMS:/root/rpmbuild/RPMS \
        bldr:latest \
        --spec-file /root/test/example.spec \
        --value-file /root/test/values.yaml \
        ;
}

main "$@"


## run the bldr
#docker run \
#    --rm \
#    -v $(PWD)/test:/root/test \
#    -v $(PWD)/SOURCES:/root/rpmbuild/SOURCES \
#    bldr:latest \
#    --spec-file /root/test/example.spec \
#    --value-file /root/test/values.yaml \
#    ;
#
