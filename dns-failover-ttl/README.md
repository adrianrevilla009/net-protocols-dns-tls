# dns-failover-ttl

A `dig` script, `check-ttl.sh`, and an example zone fragment, `failover-records.zone`, for reasoning about how fast DNS failover can be.

## Goal

Show that a cached DNS answer keeps being served until its TTL runs out, so the TTL bounds how quickly clients move to a secondary address.

## Run it

```
bash check-ttl.sh example.com 1.1.1.1 3
```

Expected: three lines like `example.com. ttl=<seconds> <address>`, two seconds apart, followed by a note that worst-case failover is the record TTL plus resolver and client caches. Arguments are name, resolver and number of samples.

Not run end to end: the script needs outbound DNS and was not executed in this environment, so no real values are quoted. The TTL shown depends on the resolver cache state, and a second query may return a lower number.

## What it proves

- `check-ttl.sh` prints the TTL column from the answer, so a falling number between samples is the resolver cache at work.
- `failover-records.zone` sets `$TTL 60` and gives `orders.example.com.` a primary (192.0.2.10) and a secondary (198.51.100.10) from documentation address ranges.
- The zone file is only an illustration: a health-checking DNS service decides when the secondary is served, and nothing in this folder loads the file into a server.

## Trade-offs

- Low TTLs speed up failover but raise query volume and resolver latency.
- Some resolvers and clients floor or ignore TTLs, so measured behaviour can be slower than the number in the zone.
- Health checks, the part that triggers failover, are described in comments only.

## When not to use it

- When failover must be near instant; use a load balancer, anycast or client-side retry across several addresses.
- To measure the JVM side of caching, use `jvm-dns-caching` instead.
