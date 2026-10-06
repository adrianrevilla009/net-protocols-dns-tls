# cdn-waf

A Terraform file, `cdn-waf.tf`, with a CloudFront distribution and a WAFv2 web ACL in front of an Orders origin.

## Goal

Show how a CDN and a web application firewall are wired together: the ACL is attached to the distribution, with a managed rule set and a per-IP rate limit.

## Run it

Validate only; the configuration is never applied:

```
terraform init -backend=false && terraform validate
```

Expected: `Success! The configuration is valid.` after the AWS provider 5.81.0 is downloaded. The provider block uses dummy keys and skips credential checks, so no account is needed.

Not run end to end: validation was not executed in this environment, and the resources have never been created in a real account. If someone applied it, a web ACL costs roughly USD 5 per month plus rule and request fees; the cleanup would be `terraform destroy`, against a throwaway account only.

## What it proves

- `web_acl_id` on `aws_cloudfront_distribution.orders` points at `aws_wafv2_web_acl.orders`, which has scope `CLOUDFRONT` and therefore the provider region `us-east-1`.
- The ACL allows by default, runs `AWSManagedRulesCommonRuleSet` as rule 1 and blocks any IP above 1000 requests in the rate window as rule 2.
- The distribution sets `http_version = "http2and3"`, redirects viewers to HTTPS, and reaches `origin.example.com` over HTTPS with TLS 1.2 only.

## Trade-offs

- Managed rules produce false positives until tuned; in real use start them in count mode.
- Caching only helps cacheable paths, and only GET, HEAD and OPTIONS are allowed here.
- The default CloudFront certificate means no custom domain; `origin.example.com` is a placeholder host.

## When not to use it

- For a purely internal service with no public edge.
- When the platform already provides edge protection, such as Cloudflare or a load balancer with its own WAF.
