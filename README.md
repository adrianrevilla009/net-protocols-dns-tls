# net-protocols-dns-tls

Ten small labs on the network layers an Orders service sits on: HTTP versions, TLS, certificates, DNS, CDN and WAF, VPNs and private cloud connectivity. Each folder is standalone and can be read in a few minutes.

## What is inside

| Folder | What it shows | Run |
| --- | --- | --- |
| [`http2-http3-compare`](./http2-http3-compare) | curl timings for one URL over HTTP/1.1, HTTP/2 and HTTP/3 | `bash compare.sh --check` |
| [`tls-handshake-openssl`](./tls-handshake-openssl) | A local TLS 1.2 or 1.3 handshake with a throwaway certificate | `bash handshake.sh tls1_3` |
| [`cert-manager-letsencrypt`](./cert-manager-letsencrypt) | cert-manager issuer, certificate and ingress for Let's Encrypt staging | `kubectl apply -f issuer-staging.yaml` |
| [`dns-failover-ttl`](./dns-failover-ttl) | A TTL counting down in a resolver cache, plus a failover zone fragment | `bash check-ttl.sh example.com 1.1.1.1 3` |
| [`cdn-waf`](./cdn-waf) | CloudFront with a WAFv2 web ACL in Terraform | `terraform init -backend=false && terraform validate` |
| [`wireguard-vpn`](./wireguard-vpn) | A generated hub and client WireGuard config pair | `bash wg-setup.sh` |
| [`tailscale-zero-trust`](./tailscale-zero-trust) | A tag-based Tailscale ACL policy with built-in tests | upload `acl.hujson` to the admin console |
| [`vpc-peering-privatelink`](./vpc-peering-privatelink) | VPC peering and PrivateLink side by side in Terraform | `terraform init -backend=false && terraform validate` |
| [`hybrid-site-to-site-vpn-notes`](./hybrid-site-to-site-vpn-notes) | A design checklist for an on-prem to cloud IPsec VPN | read `vpn-checklist.md` |
| [`jvm-dns-caching`](./jvm-dns-caching) | The JVM resolver cache settings and lookup timings | `java DnsCache.java localhost` |

## Prerequisites

- curl (HTTP/3 needs a build with QUIC support), openssl, dig
- Java 21 for `jvm-dns-caching`
- Terraform 1.9 or newer for `cdn-waf` and `vpc-peering-privatelink` (no cloud account needed)
- wireguard-tools for `wireguard-vpn`; kind and kubectl for `cert-manager-letsencrypt`

## How to read it

Start with `dns-failover-ttl` and `jvm-dns-caching` for the caching story, or `tls-handshake-openssl` for the quickest hands-on run. The Terraform and policy folders are validated offline and never applied; each README says what was and was not run.
