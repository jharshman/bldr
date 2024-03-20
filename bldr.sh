#!/bin/bash

usage() {
    cat <<EOM
Usage: $0 [options]

Options:
    --source-dir    Path to source code to build
    --rpmbuild-mnt
    --dockerfile
    --help          Display usage

Example:
    $0 --source_dir ./Projects/fwsync
EOM
}

main() {
    local _source_dir
    local _rpmbuild_mnt
    local _dockerfile
    local _specfile
    local _value_file
    local _project

    while (( $# )); do
        case "$1" in
        --source-dir)
            _source_dir=$2
            shift 2
            ;;
        --rpmbuild-mnt)
            _rpmbuild_mnt=$2
            shift 2
            ;;
        --dockerfile)
            _dockerfile=$2
            shift 2
            ;;
        --specfile)
            _specfile=$2
            shift 2
            ;;
        --value-file)
            _value_file=$2
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

    set -x
    _source_dir=$(readlink -f $_source_dir)
    #_rpmbuild_mnt=$(readlink -f $_rpmbuild_mnt)
    _project=$(basename $_source_dir)
    mkdir -p $_rpmbuild_mnt/{SOURCES,RPMS}

    pushd $_source_dir/.. > /dev/null
    tar -czv --exclude-vcs -f $_project.tar.gz $_project
    mv $_project.tar.gz $_rpmbuild_mnt/SOURCES/
    popd > /dev/null

    # run the bldr
    docker build -f $_dockerfile -t $_project-release:latest .
    docker run \
        --rm \
        -v $_source_dir:/root/src \
        -v $_rpmbuild_mnt/SOURCES:/root/rpmbuild/SOURCES \
        -v $_rpmbuild_mnt/RPMS:/root/rpmbuild/RPMS \
        $_project-release:latest \
        --spec-file /root/src/build/spec/example.spec \
        --value-file /root/src/build/spec/values.yaml \
        ;
}

main "$@"
