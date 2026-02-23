FROM alpine:3.23.3

ARG VERSION=1.4.2

## https://github.com/opencontainers/image-spec/blob/v1.1.1/annotations.md
LABEL org.opencontainers.image.url="https://github.com/travelping/docker-pcap"
LABEL org.opencontainers.image.source="https://github.com/travelping/docker-pcap"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.vendor="Travelping GmbH"
LABEL org.opencontainers.image.title="pcap-$VERSION"
LABEL org.opencontainers.image.description="pcap - capture network traffic"

RUN apk add -U --no-cache \
    coreutils \
    libcap-setcap \
    tshark=4.6.1-r0 && \
    setcap cap_net_raw+eip /usr/bin/dumpcap && \
    adduser pcap -u 65532 -h /dev/null -G wireshark -D -H

ADD run.sh /run.sh

ENV FILTER="icmp"
ENV IFACE="any"
ENV DURATION="600"
ENV MAXFILESIZE="1000"
ENV MAXFILENUM="10"
ENV FILENAME="dump"
ENV FORMAT="pcapng"
ENV SNAPLENGTH=""

RUN mkdir /data && chown 65532:101 /data

USER 65532:101

CMD [ "/bin/sh", "-c", "/run.sh" ]
