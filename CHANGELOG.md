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
