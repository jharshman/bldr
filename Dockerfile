FROM --platform=arm64 rust:1.76-slim-buster as builder

WORKDIR /usr/src/bldr
COPY . .

RUN cargo build --release

FROM --platform=arm64 opensuse/leap:15

RUN zypper in -y rpm-build rpmdevtools

# setup the rpmbuild directory tree
# creates /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
RUN rpmdev-setuptree /root/

COPY --from=builder /usr/src/bldr/target/release/bldr /bldr

ENTRYPOINT ["/bldr"]
CMD ["-h"]
