FROM alpine

RUN apk add --no-cache tcpdump coreutils

# -C max file size (creates new file counting up, unit 1 = 1,000,000 bytes))
# -W max number of created files (rotating buffer since files from the beginning are overwritten)
# -w writing the raw packets to a file rather than to stdout

ENV FILTER=""
ENV IFACE="any"

RUN mkdir /data

CMD [ "/bin/sh", "-c", "/usr/sbin/tcpdump -C 1000 -W 100 -v -w /data/dump -i $IFACE $FILTER" ]
