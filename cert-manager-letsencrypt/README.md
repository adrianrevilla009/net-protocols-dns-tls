# cert-manager-letsencrypt

One YAML file, `issuer-staging.yaml`, with a cert-manager `ClusterIssuer`, a `Certificate` and an `Ingress` for `orders.example.com`.

## Goal

Show how the pieces of automatic certificate issuance connect: an ACME issuer for Let's Encrypt staging, a certificate request, and an ingress that points at them.

## Run it

Parse the file offline (needs PyYAML, no cluster):

```
python3 -c "import yaml;print([d['kind'] for d in yaml.safe_load_all(open('issuer-staging.yaml'))])"
```

Expected: `['ClusterIssuer', 'Certificate', 'Ingress']`.

On a cluster (cert-manager v1.16.2, ingress-nginx and an `orders` Service must already exist; edit the email first):

```
kind create cluster --name certs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
kubectl apply -f issuer-staging.yaml
kubectl describe certificate orders-tls
kind delete cluster --name certs
```

Not run end to end: neither command was executed in this environment. Issuance would also fail on a local kind cluster, because the HTTP-01 challenge needs a public name that Let's Encrypt can reach. The last command removes the cluster.

## What it proves

- The `Ingress` annotation `cert-manager.io/cluster-issuer: letsencrypt-staging` links it to the issuer, and the `Certificate` and ingress `tls` block share the secret name `orders-tls`.
- The issuer uses the staging ACME URL with an HTTP-01 solver on the `nginx` ingress class.
- The renewal window is explicit: `duration: 2160h` (90 days) and `renewBefore: 720h` (30 days).

## Trade-offs

- HTTP-01 needs public reachability and cannot issue wildcards; DNS-01 can, but needs DNS provider credentials.
- Staging certificates are not trusted by browsers, which is the point, but it means the result cannot be shown to real clients.
- The email `you@example.com` and host `orders.example.com` must be replaced before use.

## When not to use it

- When a cloud load balancer already terminates TLS with a managed certificate such as ACM.
- For internal-only services, where a private CA issuer is a better fit than a public ACME one.
