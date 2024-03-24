#!/bin/bash

usage() {
    cat <<EOM
Usage: $0 [options]

Options:
    --source-dir    Path to source code to build.
    --rpmbuild-mnt  Path to rpmbuild tree mounts. This is where your RPM will show up.
    --dockerfile    Path to your Dockerfile. This Dockerfile defines the build environment.
    --specfile      Path to your app's specfile. This should be a template.
    --value-file    Path to the values file. This contains values to render the template.
    --help          Display usage

Example:
    $(basename $0) \\
        --source_dir /path/to/project/source \\
        --rpmbuild-mnt /tmp/rpmbuild/ \\
        --dockerfile /path/to/project/source/Dockerfile \\
        --specfile /path/to/project/specfile/fwsync.spec \\
        --value-file /path/to/project/values/values.yaml
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

    _source_dir=$(readlink -f $_source_dir)
    _project=$(basename $_source_dir)
    mkdir -p $_rpmbuild_mnt/{SOURCES,RPMS}

    pushd $_source_dir/.. > /dev/null
    tar -czv --exclude-vcs -f $_project.tar.gz $_project
    mv $_project.tar.gz $_rpmbuild_mnt/SOURCES/
    popd > /dev/null

    # run the bldr
    docker build -f $_dockerfile -t $_project-release:latest .
    set -x
    docker run \
        --rm \
        -v $_specfile:/root/src/$(basename $_specfile) \
        -v $_value_file:/root/src/$(basename $_value_file) \
        -v $_rpmbuild_mnt/SOURCES:/root/rpmbuild/SOURCES \
        -v $_rpmbuild_mnt/RPMS:/root/rpmbuild/RPMS \
        $_project-release:latest \
        --spec-file /root/src/$(basename $_specfile) \
        --value-file /root/src/$(basename $_value_file) \
        ;
}

main "$@"
