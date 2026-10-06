# wireguard-vpn

A shell script, `wg-setup.sh`, that generates a hub and a client WireGuard configuration with fresh keys.

## Goal

Show the minimum a two-peer WireGuard tunnel needs: a key pair per side, a tunnel address, and each peer listing the other's public key and allowed addresses.

## Run it

```
bash wg-setup.sh
```

Expected: `wrote out/wg-hub.conf out/wg-client.conf`, then a count of `[Peer]` sections (`1` for each file). If `wg` is not installed it prints an install hint and exits without writing anything.

Not run end to end: the script was not executed in this environment, and no tunnel was ever brought up. To try it, copy the files to two throwaway hosts and run `wg-quick up`; the client's `Endpoint` is `hub.example.com:51820` and must be changed to the hub's real address.

## What it proves

- The script writes keys with `umask 077` into `out/`; the `.gitignore` in the repo keeps keys and `out/` out of git, so no secret is committed.
- The hub is `10.8.0.1/24` listening on UDP 51820 and accepts only `10.8.0.2/32` from the client; the client routes `10.8.0.0/24` to the hub.
- `PersistentKeepalive = 25` on the client keeps NAT mappings open.

## Trade-offs

- Keys live as files on the machine that ran the script; a real deployment needs a way to distribute and rotate them.
- Only a split tunnel to `10.8.0.0/24` is configured; sending all traffic through the hub needs `AllowedIPs = 0.0.0.0/0` plus forwarding and NAT on the hub, which is not set up here.
- Peers are static; adding clients means editing the hub config.

## When not to use it

- For many devices or identity-based access, a coordination layer such as the one in `tailscale-zero-trust` is easier to manage.
- For connecting to a cloud provider's gateway, use that provider's IPsec VPN, see `hybrid-site-to-site-vpn-notes`.
