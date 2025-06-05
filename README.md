# PCAP capturing in a container

This container starts capturing packets and safes the captured packets in
files. It uses a ring buffer with a default file size of 1 Gigabyte and a
maximum number of files of 10. All files are stored in the `/data` directory.

## Usage

For the container to be able to capture packets on any interface of the host
system `--net=host --cap-add NET_ADMIN` needs to be passed to the docker run command.

Environment variables can be overwritten using the `-e` option of the `docker
run` command.

These options are configurable:

| Name          | default value |
|:--------------|:--------------|
| `IFACE`       |         `any` |
| `FILTER`      |      `"icmp"` |
| `MAXFILESIZE` |        `1000` |
| `MAXFILENUM`  |          `10` |
| `DURATION`    |       `"600"` |
| `FILENAME`    |        `dump` |
| `FORMAT`      |      `pcapng` |
| `SNAPLENGTH`  | <deactivated> |

`IFACE` space-separated list of interfaces dumpcap should listen on.

`FILTER` contains the filter rules that are passed to dumpcap.

`MAXFILESIZE` is the maximum size that a file can grow to before a new file
will be opened. The unit for this is Megabytes (1 Megabyte = 1,000,000 bytes).

`MAXFILENUM` is the maximum number of files that are opened before dumpcap
starts overwriting old files one by one beginning with the first one.

`DURATION` is the maximum number of seconds dumpcap waits until it begins to
write into the next file.

`INTERVAL` uses Wireshark's `Capture output: -b` option. It allows to run
"multiple files" mode, which enables to switch between capture files if a
condition is met. The value defined in `interval` will execute a switch to the
next capture file whenever the time is an *exact multiple* of `value` seconds.

The `FILENAME` variable sets the filename that is used. The default value is
`dump`. A number will be attached to each file (see [dumpcap manpage][1] for more
information).

`FORMAT` sets the file-format of the written trace. Note that when you're
setting the `FORMAT` to `pcap` for example, the `FILENAME` has to be changed
to `dump.pcap`.  Other supported format is `pcapng`.

`SNAPLENGTH` is the amount of data for each frame that is actually captured by
the network capturing tool and stored into the CaptureFile. This is sometimes
called PacketSlicing.  By default this is turned off so large packets are not
truncated by accident.

`PROMISCUOUS_MODE` defines if the given interface(s) are put into promiscous
mode or not. If set to `"yes"`, promiscous mode is used for the interfaces.
Default is: "no", interfaces are _not_ put into promiscous mode.

Example:

    $> ls -1 dump
    dump_00164_20180622110637
    dump_00165_20180622110638
    dump_00166_20180622110639
    dump_00167_20180622110640
    dump_00168_20180622110640

To extract the files, containing the captured packages, from the container to
the host, the simplest way is to mount a host folder over the data directory
using the `-v` option of the `docker run` command.

**Example:**

    $> docker run --cap-add NET_ADMIN --net=host -e IFACE="enp3s0f1" -e FILTER="tcp port 80" -v \
        $PWD/dump:/data --rm -ti travelping/pcap

After the packages are captured, they can be evaluated using tcpdumps `-r`
option to read captured raw packages from a file.

### Display Filters

`tshark` does not allow for wireshark like filters to be applied to a capture
stream. In addition, the functionality of piping to `tshark` and than applying
a read filter is also [broken][2]. As a result, applying wireshark like
filters must be done in a second filter pass.

This can be done with a local installed instance of `tshark` or using the
`tshark` provided by the docker-pcap container:

    $> docker run --net=host -v $PWD/dump:/data --rm -ti travelping/pcap /bin/sh
    / # tshark -r /path/to/file -Y <filter>


[1]: https://www.wireshark.org/docs/man-pages/dumpcap.html
[2]: https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=2234
