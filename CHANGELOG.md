## v1.6.0

- ship only the capture tools -- dumpcap, editcap, mergecap and reordercap --
  built from Wireshark 4.6.9 source; tshark, capinfos and libwireshark with
  its libraries (gnutls, libssh, lua, krb5, ...) are no longer part of the
  image, and neither are the CVEs reported against them.
- capture on regular interfaces only; 802.11 monitor mode is not supported
- use alpine:3.24.3 as base image, with `ca-certificates-bundle` 20261020
- distrust the eMudhra/emSign root CAs whose intermediates had their private
  keys compromised in 2026-10: the system CA bundle is filtered against
  `tools/ca-distrust.sha256` at build time
- start with a clean container log, and leave a mounted `/data` with its
  owner when the container runs as root: `/data` ownership is the image's
  (65532:101)

## v1.5.0

- write compressed capture files with `COMPRESS=gzip` or `COMPRESS=lz4`,
  avoiding additional compression scripts or post-processing after rotation
- use tshark in version `4.6.6-r0`
- use alpine:3.24.1 as base image
- upgrade the base packages to the versions the alpine branch currently ships
- use shell utilities from busybox instead of coreutils

## v1.4.3

- use tshark in version `4.6.5-r0`
- use alpine:3.23.4 as base image

## v1.4.2

- use tshark in version `4.6.1-r0`
- use alpine:3.23.3 as base image

## v1.4.1

- Use tshark in version `4.4.7-r0`
- Use alpine:3.22.1 as base image

## v1.4.0

- Use tshark in version `4.4.6-r0`
- Use alpine:3.22 as base image
- Change the defaults for
  * Run as user 65532, group 101 ("wireshark")
  * Deactivated promiscous mode
- Add option to use environment variable `PROMISCUOUS_MODE=yes` to
  capture in promiscous mode

## v1.3.2

- Use alpine:3.21 as base image
- Use tshark in version `4.4.2-r0`

## v1.3.1

- Use `pcap` as default file format

## v1.3.0

- Use alpine:3.17 as a base image
- Use tshark in version `4.0.1-r0`
- Use dumpcap directly instead of tshark
- Change the defaults for
  * FILTER to "icmp" (prevents unintentional capture of all traffic)
  * DURATION to 600 seconds (prevents unintentional infinity captures)
- Do not set INTERVAL and DURATION at the same time, prefer INTERVAL if both set

## v1.2.1- Feature:

- Added interval-option to tshark ring-buffer.

## v1.2.0- Feature:

- Added snaplength feature
- Specified base image as alpine:3.9

## v1.1.0- Feature:

- Reworked (experimental) formatting option

## v1.0.2- (Experimental) Feature:

- Added (experimental) formatting option

## v1.0.1

- Fix: Apply filter to all interfaces
