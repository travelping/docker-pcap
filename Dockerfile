FROM alpine

RUN apk add --no-cache tshark coreutils

# -C max file size (creates new file counting up, unit 1 = 1,000,000 bytes))
# -W max number of created files (rotating buffer since files from the 
#    beginning are overwritten)
# -w writing the raw packets to a file rather than to stdout

ADD run.sh /run.sh

ENV FILTER=""
ENV IFACE="any"
ENV MAXFILESIZE="1000"
ENV MAXFILENUM="10"
ENV FILENAME="dump"

USER root:root

RUN mkdir /data

CMD [ "/bin/sh", "-c", "/run.sh" ]
