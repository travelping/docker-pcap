FROM alpine:3.22

RUN apk add -U --no-cache coreutils libcap-setcap tshark=4.4.6-r0 && \
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
