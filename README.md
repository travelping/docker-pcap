# TCPDUMP in a container

This container starts a tcpdump and safes the captured packages in files. It
uses the `-C` option to limit the file size to 1 Gigabyte by default.  Also `-W`
is used to limit the creation of new files to 10 files by default. When the last
file has the reached the maximum size tcpdump will overwrite all files (one by
one) starting with the first one. All created files are located in the container
in the `/data` directory.

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
| `FILENAME`    |        `dump` |

`IFACE` is the interface tcpdump should listen on.

`FILTER` contains the filter rules that are passed to tcpdump.

`MAXFILESIZE` is the maximum size that a file can grow to before a new file will
be opened. The unit for this is Megabytes (1 Megabyte = 1,000,000 bytes).

`MAXFILENUM` is the maximum number of files that are opened before tcpdump
starts overwriting old files one by one beginning with the first one.

The `FILENAME` variable sets the filename that is used. The default value is 
`dump`. A number will be attached to each file, counting up starting with `0`.

Example:

```
-> % ls -1 dump 
dump0
dump1
dump2
dump3
dump4
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
