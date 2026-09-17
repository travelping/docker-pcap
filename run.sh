#!/bin/sh
set -x

# FIX: since tshark wont write to a directory that is not owned by the user
# executing the command
chown root:root /data

INTERFACE=""
BUFFEROPTS=""

for INTERFACE in $IFACE;
do
  INTERFACES="$INTERFACES -i $INTERFACE"
done

# -b filesize:
#          max file size (creates new file counting up, unit 1 = 1,000
#          bytes))
#    files: max number of created files (rotating buffer since files from the
#          beginning are overwritten)
#    duratioin: number of seconds that a file will be kept before rotating
# -w writing the raw packets to a file rather than to stdout

if [ -n "$MAXFILESIZE" ];
then
  BUFFEROPTS="$BUFFEROPTS -b filesize:${MAXFILESIZE}000"
fi

if [ -n "$MAXFILENUM" ];
then
  BUFFEROPTS="$BUFFEROPTS -b files:$MAXFILENUM"
fi

# interval and duration cannot be set at the same time
if [ -n "$DURATION" ] && [ -z "$INTERVAL" ];
then
  BUFFEROPTS="$BUFFEROPTS -b duration:$DURATION"
fi

if [ -n "$INTERVAL" ];
then
  BUFFEROPTS="$BUFFEROPTS -b interval:$INTERVAL"
fi

if [ -n "$SNAPLENGTH" ];
then
  SNAPLENGTH="-s $SNAPLENGTH"
fi

PCAPNG=""
if [ "$FORMAT" = "pcap" ];
then
  # -P deprecated since tshark:4.4 ~ 2024
  PCAPNG="-F pcap"
fi

PMODE="--no-promiscuous-mode"
if [ "$PROMISCUOUS_MODE" = "yes" ];
then
  PMODE=""
fi

# gzip and lz4 are the formats dumpcap writes; the matching suffix is appended
# to the file name by dumpcap itself. Empty means uncompressed.
COMPRESSOPTS=""
if [ -n "$COMPRESS" ];
then
  COMPRESSOPTS="--compress $COMPRESS"
fi

/usr/bin/dumpcap $PMODE $PCAPNG $COMPRESSOPTS $BUFFEROPTS -w "/data/$FILENAME" -f "$FILTER" $INTERFACES $SNAPLENGTH
