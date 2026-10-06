# hybrid-site-to-site-vpn-notes

A one-page design checklist, `vpn-checklist.md`, for an IPsec VPN between an on-premises network and a cloud VPC.

## Goal

Capture the decisions that make a site-to-site VPN reliable: routing, redundancy, crypto, address plan, MTU, throughput, DNS and monitoring.

## Run it

There is nothing to execute; read the checklist:

```
cat vpn-checklist.md
```

Expected: a table of nine decisions with the choice and the reason for each, followed by a short test plan.

Not run end to end: this folder is documentation only. No VPN was built and no value in the table was tested.

## What it proves

- The checklist picks BGP over static routes and two tunnels to different endpoints, so a single tunnel maintenance event does not cut traffic.
- Concrete numbers are given: IKEv2 with AES-256-GCM, example CIDRs `192.168.0.0/16` and `10.0.0.0/16`, tunnel MTU 1400 with TCP MSS clamped to 1360, and about 1.25 Gbps per tunnel.
- The test plan is specific: ping across, `tracepath -n` to find MTU problems, then take one tunnel down and confirm traffic moves within the BGP hold time.

## Trade-offs

- The numbers are typical starting values for AWS, not guarantees; check the provider's current limits.
- A checklist cannot catch vendor-specific quirks of your on-premises device.
- DNS is a one-line item here (conditional forwarders both ways); in practice it needs its own design.

## When not to use it

- When throughput or latency needs exceed a VPN, plan a dedicated link such as Direct Connect instead.
- When only one service must be shared, `vpc-peering-privatelink` shows a smaller option inside the cloud.
