# tls-handshake-openssl

A shell script, `handshake.sh`, that starts a local `openssl s_server` with a throwaway certificate and connects to it with `openssl s_client`.

## Goal

Let you watch a TLS 1.2 or TLS 1.3 handshake complete end to end on your own machine, with nothing external involved, and check which protocol was negotiated.

## Run it

```
bash handshake.sh tls1_3
bash handshake.sh tls1_2
```

Expected: a few filtered lines from the client (subject, verification result, cipher and protocol) and a final `OK negotiated TLSv1.3` or `OK negotiated TLSv1.2`. Nothing is printed after the filtered lines if the protocol does not match.

Not run end to end: the script was not executed in this environment, so the output above is described from the code, not copied from a run.

## What it proves

- `handshake.sh` creates a one-day self-signed certificate for `localhost` in a temp directory and removes it on exit, along with the server process.
- The client trusts that certificate through `-CAfile`, so verification succeeds without disabling checks.
- The version argument pins both sides (`-tls1_2` or `-tls1_3`), and the last line only prints when the client output reports that protocol.

## Trade-offs

- The server uses a random port between 20000 and 29999 and a fixed one-second sleep, so a slow machine could connect before the server is ready.
- Output parsing depends on the wording of `openssl s_client`, which differs between OpenSSL 1.1 and 3.x.
- A self-signed certificate shows nothing about chain building or revocation.

## When not to use it

- To test a real server's configuration, use `openssl s_client -connect host:443` directly or a scanner.
- To study certificate chains, issuance or renewal, see `cert-manager-letsencrypt`.
