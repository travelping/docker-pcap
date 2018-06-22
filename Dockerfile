FROM alpine

RUN apk add --no-cache tshark coreutils

ADD run.sh /run.sh

ENV FILTER=""
ENV IFACE="any"
ENV MAXFILESIZE="1000"
ENV MAXFILENUM="10"
ENV FILENAME="dump"

USER root:root

RUN mkdir /data

CMD [ "/bin/sh", "-c", "/run.sh" ]
