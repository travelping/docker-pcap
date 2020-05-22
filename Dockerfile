FROM alpine:3.11

RUN apk add --no-cache \
        coreutils \
        'tshark=3.0.11-r0'

ADD run.sh /run.sh

ENV FILTER="icmp"
ENV IFACE="any"
ENV DURATION="600"
ENV MAXFILESIZE="1000"
ENV MAXFILENUM="10"
ENV FILENAME="dump"
ENV FORMAT="pcapng"
ENV SNAPLENGTH=""

USER root:root

RUN mkdir /data

CMD [ "/bin/sh", "-c", "/run.sh" ]
