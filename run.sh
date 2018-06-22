#!/bin/sh

INTERFACE=""

for INTERFACE in $IFACE;
do
  INTERFACES="$INTERFACES -i $INTERFACE"
done

/usr/bin/tshark  -b filesize:$MAXFILESIZE -b files:$MAXFILENUM -w \
  "/data/$FILENAME" $INTERFACES $FILTER

