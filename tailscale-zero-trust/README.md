# tailscale-zero-trust

A Tailscale tailnet policy file, `acl.hujson`, with tags, groups, access rules and a test.

## Goal

Show tag-based, deny-by-default access for the Orders service: who may reach the API, who may reach the database, and who may SSH.

## Run it

There is no local validator. Paste `acl.hujson` into the access controls editor of a Tailscale admin console; it evaluates the `tests` block when you save. To read the policy locally:

```
cat acl.hujson
```

Expected: the policy saves, and the test passes (the developer reaches `tag:orders-api:443` but not `tag:orders-db:5432`).

Not run end to end: no tailnet was available, so the policy was never loaded and the test never evaluated. The file is HuJSON (JSON with comments and trailing commas), so a plain JSON parser rejects it.

## What it proves

- Tags own the nodes: `tag:orders-api` and `tag:orders-db` are managed by `group:platform`.
- Three rules grant access: `group:dev` to the API on port 443, the API to the database on 5432, and `group:platform` to SSH on port 22 of both tags.
- Anything not listed is denied, and the `tests` entry for `dev@example.com` asserts that the database is unreachable for developers.

## Trade-offs

- Tags replace per-machine rules, but someone must control who may apply them.
- Users in `groups` are placeholder addresses at `example.com` and must be replaced.
- ACLs control reachability only; they do not inspect application-level permissions.

## When not to use it

- If you need an open-source, self-hosted control plane, evaluate a self-hosted alternative; this file only works with Tailscale's own service.
- For a single point-to-point tunnel, plain WireGuard (`wireguard-vpn`) is simpler.
