#!/usr/bin/env bash
# Time the same URL over HTTP/1.1, HTTP/2 and HTTP/3 with curl.
# Usage: compare.sh [url] [runs]   |   compare.sh --check  (offline: report protocol support only)
set -u
if [ "${1:-}" = "--check" ]; then
  feats=$(curl -V | tr ' ' '\n' | grep -Ex 'HTTP2|HTTP3' | tr '\n' ' ')
  echo "curl $(curl -V | awk 'NR==1{print $2}') features: ${feats:-none}"
  exit 0
fi
url=${1:-https://example.com/}
runs=${2:-5}
fmt='%{http_version} connect=%{time_connect}s tls=%{time_appconnect}s ttfb=%{time_starttransfer}s total=%{time_total}s\n'
for flag in --http1.1 --http2 --http3; do
  echo "== $flag"
  for _ in $(seq "$runs"); do
    curl -sS -o /dev/null -m 10 "$flag" -w "$fmt" "$url" 2>&1 | head -1 || true
  done
done
