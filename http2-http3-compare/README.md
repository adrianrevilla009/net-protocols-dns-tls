# http2-http3-compare

One shell script, `compare.sh`, that times the same URL with curl over HTTP/1.1, HTTP/2 and HTTP/3.

## Goal

Make the handshake cost of each HTTP version visible: connect time, TLS time, time to first byte and total time, side by side for one URL.

## Run it

```
bash compare.sh --check                  # offline: which protocols this curl supports
bash compare.sh https://example.com/ 5   # needs network; 5 runs per protocol
```

Expected: `--check` prints the curl version and whether `HTTP2` and `HTTP3` appear in its feature list. The timing run prints one line per request such as `2 connect=... tls=... ttfb=... total=...`, grouped under `== --http1.1`, `== --http2` and `== --http3`.

Not run end to end: the scripts were not executed in this environment, so no timings are quoted here. Many curl builds lack HTTP/3, and then the HTTP/3 group prints a curl error instead of a timing line.

## What it proves

- The output format in `compare.sh` shows `time_connect` and `time_appconnect` separately, which is where HTTP/3 over QUIC differs: it merges the transport and TLS handshakes.
- `--check` tells you before any network call whether the HTTP/3 rows can work.
- Running several samples per protocol shows how noisy single measurements are.

## Trade-offs

- Each curl run opens a fresh connection, so multiplexing and connection reuse gains are not measured.
- Results depend on the server, any CDN in front and the network path.
- Output of `head -1` per request keeps the log short but hides curl error detail beyond the first line.

## When not to use it

- For load-level numbers, use a tool such as h2load.
- For long-lived multiplexing behaviour, browser devtools show more than one-shot curl runs.
