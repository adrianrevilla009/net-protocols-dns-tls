# vpc-peering-privatelink

A Terraform file, `main.tf`, that builds two AWS VPCs and connects them twice: with VPC peering and with a PrivateLink endpoint service.

## Goal

Contrast the two ways to let one VPC reach another: peering gives routed access between whole networks, PrivateLink exposes a single service.

## Run it

Validate only; the configuration is never applied:

```
terraform init -backend=false && terraform validate
```

Expected: `Success! The configuration is valid.` once the AWS provider 5.81.0 is downloaded. The provider uses dummy keys and skips credential checks.

Not run end to end: validation was not executed in this environment, and nothing was created in a real account. For cost reference, an interface endpoint is about USD 0.01 per hour per AZ plus data, and peering charges only for cross-AZ or cross-region transfer. Cleanup, if ever applied to a throwaway account, is `terraform destroy`.

## What it proves

- Peering: `aws_vpc_peering_connection.peer` links `10.1.0.0/16` and `10.2.0.0/16`, and the consumer route table sends `10.2.0.0/16` through it. The CIDRs must not overlap.
- PrivateLink: an internal network load balancer is published as `aws_vpc_endpoint_service.orders` (acceptance required), and the consumer reaches it via an `Interface` endpoint in its own subnet.
- The peering path needs routes on both sides for full reachability; this file defines only the consumer's route table.

## Trade-offs

- Peering is transitive-free and exposes every reachable address, so security groups carry the whole access policy.
- PrivateLink limits exposure to one service and tolerates overlapping CIDRs, at an hourly endpoint cost.
- The network load balancer has no listener or targets, and the peering route table is not associated with a subnet, so this shows structure rather than working traffic.

## When not to use it

- To copy into production as is; it omits listeners, security groups, the provider-side routes and DNS.
- For more than a handful of VPCs, a transit gateway scales better than many peerings.
