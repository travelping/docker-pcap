#!/bin/sh

# FIX: since tshark wont write to a directory that is not owned by the user 
# executing the command
chown root:root /data

INTERFACE=""

for INTERFACE in $IFACE;
do
  INTERFACES="$INTERFACES -i $INTERFACE"
done

# -b filesize:
#          max file size (creates new file counting up, unit 1 = 1,000,000 
#          bytes))
#    files: max number of created files (rotating buffer since files from the 
#          beginning are overwritten)
# -w writing the raw packets to a file rather than to stdout

/usr/bin/tshark  -b filesize:$MAXFILESIZE -b files:$MAXFILENUM -w \
  "/data/$FILENAME" $INTERFACES $FILTER
