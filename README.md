# TCPDUMP in a container

This container starts a tcpdump and safes the captured packages in files. It
uses the `-C` option to limit the file size to 1 Gigabyte. Also `-W` is used to
limit the creation of new files to 10 files. When the last file has the reached
the maximum size (1 Gigabyte) tcpdump will overwrite all files (one by one)
starting with the first one. All created files are located in the container in
the `/data` directory.

## Usage

For the container to be able to capture packages on any interface of the host
system `--net=host` needs to be passed to the docker run command.

The interface can be set by overwriting the `IFACE` variable using the `-e`
option. The default value is `any`.

The filter rules can be specified by setting the `FILTER` variable also using
the `-e` option. The default value is an empty string resulting in tcpdump
capturing all packages.

To extract the files, containing the captured packages, from the container to
the host, the simplest way is to mount a host folder over the data directory
using the `-v` option of the `docker run` command.

**Example:**

```
-> % docker run --net=host -e IFACE="enp3s0f1" -e FILTER="tcp port 80" -v $PWD/dump:/data --rm -ti werft.tpip.net/wfailla/docker-tcpdump
```

After the packages are captured, they can be evaluated using tcpdumps `-r`
option to read captured raw packages from a file.
