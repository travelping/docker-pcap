#!/bin/sh
# Usage: tools/ca-distrust.sh <bundle> <fingerprint-list>
#
# Rewrites the PEM <bundle> in place without the certificates whose SHA-256
# fingerprint is listed in <fingerprint-list> (see tools/ca-distrust.sha256).
#
# Runs on the bird images themselves, which carry no openssl binary: the
# fingerprint is the sha256sum of the base64-decoded PEM body, all busybox.
set -eu

BUNDLE=$1
LIST=$2

deny=$(awk '!/^[[:space:]]*(#|$)/ { print tolower($1) }' "$LIST")
[ -n "$deny" ] || { echo "no fingerprints in $LIST" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# One file per certificate, numbered to keep the bundle order.
awk -v dir="$tmp" '
    /-----BEGIN CERTIFICATE-----/ { n++; file = sprintf("%s/%04d.pem", dir, n); in_cert = 1 }
    in_cert { print > file }
    /-----END CERTIFICATE-----/ { close(file); in_cert = 0 }
' "$BUNDLE"

kept=0
dropped=0
for cert in "$tmp"/*.pem; do
    fp=$(grep -E '^[A-Za-z0-9+/=]+$' "$cert" | base64 -d | sha256sum | cut -d' ' -f1)
    if printf '%s\n' "$deny" | grep -qx "$fp"; then
        echo "ca-distrust: dropped $fp" >&2
        dropped=$((dropped + 1))
        continue
    fi
    cat "$cert" >>"$tmp/bundle"
    kept=$((kept + 1))
done

[ "$kept" -gt 0 ] || { echo "ca-distrust: no certificate left in $BUNDLE" >&2; exit 1; }

cat "$tmp/bundle" >"$BUNDLE"
echo "ca-distrust: $BUNDLE: kept $kept, dropped $dropped" >&2
