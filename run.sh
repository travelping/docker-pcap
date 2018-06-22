#!/bin/sh

# FIX: since tshark wont write to a directory that is not owned by the user 
# executing the command
chown root:root /data

INTERFACE=""

for INTERFACE in $IFACE;
do
  INTERFACES="$INTERFACES -i $INTERFACE"
done

/usr/bin/tshark  -b filesize:$MAXFILESIZE -b files:$MAXFILENUM -w \
  "/data/$FILENAME" $INTERFACES $FILTER

