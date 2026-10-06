# Site-to-site VPN design checklist (Orders hybrid example)

| Decision | Choice in this sketch | Why |
|---|---|---|
| Routing | BGP, dynamic | Failover between the two tunnels without manual route edits |
| Tunnels | 2 per connection, different AWS endpoints | Provider maintenance takes one tunnel at a time |
| IKE | IKEv2, AES-256-GCM, DH group 14+ | Avoid IKEv1 and legacy groups |
| CIDRs | On-prem 192.168.0.0/16, cloud 10.0.0.0/16 | Must not overlap; plan before connecting |
| MTU | 1400 inside tunnel, clamp TCP MSS to 1360 | IPsec overhead causes silent fragmentation drops |
| Throughput | ~1.25 Gbps per tunnel cap | Use Direct Connect or ECMP over several connections beyond that |
| DNS | Conditional forwarders both ways | Names must resolve across the link |
| Monitoring | Tunnel state + BGP session alarms | A down tunnel with a healthy peer is the common silent failure |

Test plan: ping across, `tracepath -n` for MTU, pull one tunnel and confirm traffic moves to the other within the BGP hold time.
