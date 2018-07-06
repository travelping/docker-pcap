# TSHARK in a container

This container starts a tshark and safes the captured packages in files. IT 
uses a ring buffer with a default file size of 1 Gigabyte and a maximum number 
of files of 10. All files are stored in the `/data` directory.

## Usage

For the container to be able to capture packages on any interface of the host
system `--net=host` needs to be passed to the docker run command.

Environment variables can be overwritten using the `-e` option of the `docker
run` command.

These options are configurable:

| Name          | default value |
|:--------------|:--------------|
| `IFACE`       |         `any` |
| `FILTER`      |          `""` |
| `MAXFILESIZE` |        `1000` |
| `MAXFILENUM`  |          `10` |
| `DURATION`    |          `""` |
| `FILENAME`    |        `dump` |

`IFACE` is the interface tshark should listen on.

`FILTER` contains the filter rules that are passed to tshark.

`MAXFILESIZE` is the maximum size that a file can grow to before a new file will
be opened. The unit for this is Megabytes (1 Megabyte = 1,000,000 bytes).

`MAXFILENUM` is the maximum number of files that are opened before tshark
starts overwriting old files one by one beginning with the first one.

`DURATION` is the maximum number of seconds tshark waits until it begins to 
write into the next file.

The `FILENAME` variable sets the filename that is used. The default value is 
`dump`. A number will be attached to each file (see tshark manpage for more 
information). To dump on multiple interfaces simply add more interfaces to this 
variable seperated by a whitespace (e.g. "eth0 eth1").

Example:

```
-> % ls -1 dump 
dump_00164_20180622110637
dump_00165_20180622110638
dump_00166_20180622110639
dump_00167_20180622110640
dump_00168_20180622110640
```

To extract the files, containing the captured packages, from the container to
the host, the simplest way is to mount a host folder over the data directory
using the `-v` option of the `docker run` command.

**Example:**

```
-> % docker run --net=host -e IFACE="enp3s0f1" -e FILTER="tcp port 80" -v \
$PWD/dump:/data --rm -ti travelping/pcap
```

After the packages are captured, they can be evaluated using tcpdumps `-r`
option to read captured raw packages from a file.
