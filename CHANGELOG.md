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
