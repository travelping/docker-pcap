## NEXT- Feature:

- Use tshark-4.0
- Use alpine:3.17 as base image
- Change the defaults for
  * FILTER to "icmp" (prevents unintentional capture of all traffic)
  * DURATION to 600 seconds (prevents unintentional infinity captures)

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
