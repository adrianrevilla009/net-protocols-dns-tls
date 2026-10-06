#!/usr/bin/env bash
# Watch a record's TTL count down in a resolver cache, to reason about DNS failover time.
# Usage: check-ttl.sh [name] [resolver] [samples]
set -u
name=${1:-example.com}
resolver=${2:-1.1.1.1}
samples=${3:-3}
for _ in $(seq "$samples"); do
  dig +noall +answer +time=3 +tries=1 "@$resolver" "$name" A | awk '{print $1, "ttl=" $2, $5}'
  sleep 2
done
echo "Worst-case failover = record TTL + resolver negative/stale handling + client caches (JVM, OS)."
