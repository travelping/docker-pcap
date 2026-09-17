## Capture image: dumpcap and the capture-file tools built from source, without
## the rest of wireshark.
##
## Alpine ships dumpcap inside the wireshark-common package, together with
## libwireshark, sharkd and their whole link chain -- gnutls, libssh, lua,
## libsmi, maxminddb, speexdsp, krb5, brotli, c-ares. Nothing in that chain is
## reachable from dumpcap, but all of it lands in the image and in every scan
## report. Building the handful of CMake targets this image actually uses drops
## all of it: none of them links epan, so libwireshark is never built.
##
## dumpcap links wsutil and writecap statically; editcap, mergecap and
## reordercap link libwiretap and libwsutil as shared libraries, which is why
## those two are copied out of the builder alongside the binaries.
##
## capinfos is deliberately not built: it is the only one of these tools that
## links gcrypt, for the file hashes behind its -H flag, and busybox sha256sum
## covers that.

ARG ALPINE_VERSION=3.24.1
ARG VERSION=1.5.0

FROM alpine:${ALPINE_VERSION} AS build

## Independent of what the alpine branch packages, so this can sit on a release
## the branch has not picked up yet -- as it does today, with v3.24 on 4.6.6.
ARG WIRESHARK_VERSION=4.6.8
## From https://www.wireshark.org/download/SIGNATURES-4.6.8.txt
ARG WIRESHARK_SHA256=c0f1ccf217bc0d3b51a9c03ea178b0f7df682e475da26a2d21cd4a1bdd9579d0

## c-ares, pcre2, libxml2 and gcrypt are configure-time only: wireshark's
## find_package() calls for them are unconditional, even though the dumpcap
## target links none of them.
RUN apk upgrade --no-cache && \
    apk add --no-cache \
    bison \
    build-base \
    c-ares-dev \
    cmake \
    flex \
    glib-dev \
    libcap-dev \
    libgcrypt-dev \
    libpcap-dev \
    libxml2-dev \
    lz4-dev \
    pcre2-dev \
    python3 \
    samurai \
    zlib-dev

WORKDIR /src

RUN wget -q "https://www.wireshark.org/download/src/all-versions/wireshark-${WIRESHARK_VERSION}.tar.xz" && \
    echo "${WIRESHARK_SHA256}  wireshark-${WIRESHARK_VERSION}.tar.xz" | sha256sum -c - && \
    tar xf "wireshark-${WIRESHARK_VERSION}.tar.xz"

## Every other program is switched off so that a plain `cmake --build` cannot
## start dragging in the libraries this image exists to avoid. The optional
## dependencies not named here (gnutls, lua, smi, maxminddb, ...) need no flag:
## their -dev packages are simply absent from this stage, so find_package skips
## them.
##
## ENABLE_CAP=ON keeps dumpcap's privilege handling, which is what lets it run
## as an unprivileged uid with a file capability. ENABLE_NETLINK=OFF drops
## libnl, and with it 802.11 monitor mode -- this image captures on ordinary
## interfaces.
##
## Compression is gzip and lz4, the two formats dumpcap can write: wiretap's
## table in file_wrappers.c marks zstd can_write_compressed=false, and writecap,
## which dumpcap writes live captures through, implements gzip and lz4 only.
##
## ENABLE_ZSTD=OFF follows from that. Reading zstd would only matter for capture
## files from elsewhere, and editcap here only ever reads what this container
## produced -- which cannot be zstd. Leaving it off keeps libzstd out of the
## image and out of its CVE reports.
RUN cmake -S "wireshark-${WIRESHARK_VERSION}" -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_PCAP=ON \
    -DENABLE_CAP=ON \
    -DENABLE_ZLIB=ON \
    -DENABLE_LZ4=ON \
    -DENABLE_ZSTD=OFF \
    -DENABLE_NETLINK=OFF \
    -DENABLE_PLUGINS=OFF \
    -DENABLE_LUA=OFF \
    -DENABLE_LIBSSH=OFF \
    -DENABLE_SINSP=OFF \
    -DENABLE_WERROR=OFF \
    -DBUILD_dumpcap=ON \
    -DBUILD_wireshark=OFF \
    -DBUILD_stratoshark=OFF \
    -DBUILD_strato=OFF \
    -DBUILD_tshark=OFF \
    -DBUILD_tfshark=OFF \
    -DBUILD_rawshark=OFF \
    -DBUILD_sharkd=OFF \
    -DBUILD_text2pcap=OFF \
    -DBUILD_mergecap=ON \
    -DBUILD_reordercap=ON \
    -DBUILD_editcap=ON \
    -DBUILD_capinfos=OFF \
    -DBUILD_captype=OFF \
    -DBUILD_randpkt=OFF \
    -DBUILD_randpktdump=OFF \
    -DBUILD_dftest=OFF \
    -DBUILD_fuzzshark=OFF \
    -DBUILD_mmdbresolve=OFF \
    -DBUILD_sdjournal=OFF \
    -DBUILD_androiddump=OFF \
    -DBUILD_sshdump=OFF \
    -DBUILD_ciscodump=OFF \
    -DBUILD_dpauxmon=OFF \
    -DBUILD_udpdump=OFF \
    -DBUILD_wifidump=OFF \
    -DBUILD_corbaidl2wrs=OFF \
    -DBUILD_dcerpcidl2wrs=OFF \
    -DBUILD_xxx2deb=OFF && \
    cmake --build build --target dumpcap editcap mergecap reordercap

FROM alpine:${ALPINE_VERSION}

ARG VERSION

## https://github.com/opencontainers/image-spec/blob/v1.1.1/annotations.md
LABEL org.opencontainers.image.url="https://github.com/travelping/docker-pcap"
LABEL org.opencontainers.image.source="https://github.com/travelping/docker-pcap"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.vendor="Travelping GmbH"
LABEL org.opencontainers.image.title="pcap-$VERSION"
LABEL org.opencontainers.image.description="pcap - capture network traffic"

## wireshark's CMake puts both the executables and the shared libraries in
## <build>/run.
COPY --from=build /src/build/run/dumpcap /src/build/run/editcap \
                  /src/build/run/mergecap /src/build/run/reordercap /usr/bin/
COPY --from=build /src/build/run/libwiretap.so* /src/build/run/libwsutil.so* /usr/lib/

## The runtime packages are whatever the binaries actually link, asked of them
## rather than maintained by hand: apk resolves `so:` names through the packages
## that provide them. libwiretap and libwsutil are filtered out -- they come from
## the builder, no package provides them. pax-utils and setcap are build-time
## only and leave again in the same layer; the so: packages entered world just
## before, so apk keeps the ones the binaries need.
##
## setcap runs here rather than in the builder because capabilities live in an
## extended attribute, and COPY --from does not carry those across stages.
##
## gid 101 / the wireshark group are created here because nothing installs them
## any more -- they used to come from wireshark-common.
RUN apk upgrade --no-cache && \
    apk add --no-cache --virtual .setup pax-utils libcap-setcap && \
    apk add --no-cache $(scanelf --needed --nobanner --format '%n#p' \
            /usr/bin/dumpcap /usr/bin/editcap /usr/bin/mergecap /usr/bin/reordercap \
            /usr/lib/libwiretap.so* /usr/lib/libwsutil.so* \
        | awk -F'#' '{ n = split($1, libs, ","); for (i = 1; i <= n; i++) \
              if (libs[i] !~ /^(-|lib(wiretap|wsutil)\.so)/ && !seen[libs[i]]++) \
                  print "so:" libs[i] }') && \
    setcap cap_net_raw+eip /usr/bin/dumpcap && \
    apk del .setup && \
    addgroup -g 101 wireshark && \
    adduser pcap -u 65532 -h /dev/null -G wireshark -D -H

COPY --chmod=0755 run.sh /run.sh

ENV FILTER="icmp"
ENV IFACE="any"
ENV DURATION="600"
ENV MAXFILESIZE="1000"
ENV MAXFILENUM="10"
ENV FILENAME="dump"
ENV FORMAT="pcapng"
ENV SNAPLENGTH=""
## gzip or lz4; empty writes uncompressed files.
ENV COMPRESS=""

RUN mkdir /data && chown 65532:101 /data

USER 65532:101

CMD [ "/bin/sh", "-c", "/run.sh" ]
