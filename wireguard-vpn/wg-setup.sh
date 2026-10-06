#!/usr/bin/env bash
# Generate a two-peer WireGuard config pair (hub + client) into ./out. Keys are generated at run time
# and git-ignored (*.key, out/). Nothing is brought up: use `wg-quick up` yourself on a throwaway host.
# Usage: wg-setup.sh
set -eu
command -v wg >/dev/null || { echo "wg not installed: apt install wireguard-tools"; exit 0; }
mkdir -p out && cd out
umask 077
wg genkey | tee hub.key | wg pubkey > hub.pub
wg genkey | tee client.key | wg pubkey > client.pub
cat > wg-hub.conf <<EOF
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = $(cat hub.key)

[Peer]
PublicKey = $(cat client.pub)
AllowedIPs = 10.8.0.2/32
EOF
cat > wg-client.conf <<EOF
[Interface]
Address = 10.8.0.2/24
PrivateKey = $(cat client.key)

[Peer]
PublicKey = $(cat hub.pub)
Endpoint = hub.example.com:51820
AllowedIPs = 10.8.0.0/24
PersistentKeepalive = 25
EOF
echo "wrote out/wg-hub.conf out/wg-client.conf"
grep -c '^\[Peer\]' wg-hub.conf wg-client.conf
