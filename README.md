# TSHARK in a container

This container starts a tshark and safes the captured packages in files. It
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
| `FORMAT`      |      `pcapng` |
| `SNAPLENGTH`  | <deactivated> |

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

`FORMAT` sets the file-format of the written trace. Note that when you're setting
the `FORMAT` to `pcap` for example, the `FILENAME` has to be changed to `dump.pcap`.
Other formats are described in the [official tshark documentation](https://www.wireshark.org/docs/man-pages/tshark.html).

`SNAPLENGTH` is the amount of data for each frame that is actually captured by the
network capturing tool and stored into the CaptureFile. This is sometimes called PacketSlicing.
By default this is turned off so large packets are not truncated by accident.

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

### Display Filters

Since `tshark` does not allow for wireshark like filters to be applied to a
capture stream. And the functionality of piping to a `tshark` and than applying
a read filter is also broken (see
https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=2234), applying wireshark
like filters needs to be done in a second filter pass.

This can be done with a local installed instance of `tshark` or using the
`tshark` provided by the docker-pcap container:

```
-> % docker run --net=host -v $PWD/dump:/data --rm -ti travelping/pcap /bin/sh
/ # tshark -r /path/to/file -Y <filter>
```
