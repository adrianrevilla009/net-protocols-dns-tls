#!/usr/bin/env bash
# Inspect a TLS handshake locally: throwaway self-signed cert, openssl s_server, openssl s_client.
# Usage: handshake.sh [tls1_2|tls1_3]
set -eu
ver=${1:-tls1_3}
d=$(mktemp -d); pid=
trap '[ -n "$pid" ] && kill "$pid" 2>/dev/null; rm -rf "$d"' EXIT
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$d/k" -out "$d/c" -days 1 \
  -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost" 2>/dev/null
port=$((20000 + RANDOM % 10000))
openssl s_server -accept "$port" -cert "$d/c" -key "$d/k" -"$ver" -www >/dev/null 2>&1 &
pid=$!
sleep 1
out=$(echo | openssl s_client -connect "localhost:$port" -servername localhost -CAfile "$d/c" -"$ver" 2>&1 || true)
echo "$out" | grep -E '^(New, |Verification|subject=)|Protocol  *:' | head -8
want=${ver/tls1_/TLSv1.}
echo "$out" | grep -qE "Protocol *: $want" && echo "OK negotiated $want"
