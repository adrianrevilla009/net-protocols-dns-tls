# jvm-dns-caching

A single-file Java program, `DnsCache.java`, that prints the JVM's DNS cache settings and times three lookups of one host.

## Goal

Show that the JVM keeps its own DNS cache, controlled by `networkaddress.cache.ttl`, separate from the TTL on the DNS record. This is the last link in the failover chain after resolver caches.

## Run it

```
java DnsCache.java localhost
```

Output from a real run (Java 21, no security manager, default settings):

```
networkaddress.cache.ttl = null
networkaddress.cache.negative.ttl = 10
lookup 0: 127.0.0.1 in 28225 us
lookup 1: 127.0.0.1 in 87 us
lookup 2: 127.0.0.1 in 50 us
```

Pass another hostname as the first argument to try a real name; that needs a working resolver.

## What it proves

- The first lookup costs milliseconds and the next two cost microseconds, so the second and third are served from the JVM cache.
- `networkaddress.cache.ttl = null` means the JVM default applies (a short positive cache of about 30 seconds without a security manager); failed lookups are cached for 10 seconds.
- The program only reads the properties. Changing them is done in `java.security` or with `Security.setProperty` before the first lookup.

## Trade-offs

- A short cache TTL makes the JVM follow DNS changes sooner but adds lookup latency and resolver load.
- A value of `-1` caches forever, which breaks DNS-based failover until the process restarts.
- Timings of a single run are noisy; the output shows the order of magnitude, not a benchmark.

## When not to use it

- To tune a production service: measure against its real resolver and traffic instead of `localhost`.
- When the application resolves through a library with its own cache (for example a service mesh sidecar), the JVM setting alone does not decide the behaviour.
