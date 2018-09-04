FROM alpine:edge

RUN apk add --no-cache tshark=2.6.2-r0 coreutils

ADD run.sh /run.sh

ENV FILTER=""
ENV IFACE="any"
ENV MAXFILESIZE="1000"
ENV MAXFILENUM="10"
ENV FILENAME="dump"
ENV INTERVAL="30"

USER root:root

RUN mkdir /data

CMD [ "/bin/sh", "-c", "/run.sh" ]
