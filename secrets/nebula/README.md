# Nebula PKI Bootstrap Guide

This directory holds the Nebula CA certificate, host certificates, and
agenix-encrypted private keys for the `nebula.thehellings.com` overlay network.

## CIDR
`10.157.0.0/16`

## Host IP Assignments

| Host      | Nebula IP    | Role                  |
|-----------|-------------|----------------------|
| linode    | 10.157.0.1  | Lighthouse + relay    |
| genesis   | 10.157.0.2  | LAN router (unsafe)  |
| hosea     | 10.157.0.3  | Regular node          |
| isaiah    | 10.157.0.4  | Regular node          |
| jeremiah  | 10.157.0.5  | Regular node          |
| zeke      | 10.157.0.6  | Regular node          |
| exodus    | 10.157.0.7  | Regular node (laptop) |

---

## Step 1 — Install nebula-cert

```bash
nix shell nixpkgs#nebula
```

## Step 2 — Create the CA

Run once; keep `ca.key` offline/safe (do NOT commit it):

```bash
nebula-cert ca -name "thehellings.com" -out-crt ca.crt -out-key ca.key
```

Commit `ca.crt` (public) to the repo at `secrets/nebula/ca.crt`.
Store `ca.key` securely (password manager / offline).

## Step 3 — Sign host certificates

For most hosts (no subnet routing):
```bash
nebula-cert sign -ca-crt ca.crt -ca-key ca.key \
  -name <hostname> \
  -ip <nebulaIp>/16 \
  -out-crt secrets/nebula/<hostname>.crt \
  -out-key secrets/nebula/<hostname>.key
```

For **genesis** (routes the home LAN `10.42.0.0/16`), add `-subnets`:
```bash
nebula-cert sign -ca-crt ca.crt -ca-key ca.key \
  -name genesis \
  -ip 10.157.0.2/16 \
  -subnets '10.42.0.0/16' \
  -out-crt secrets/nebula/genesis.crt \
  -out-key secrets/nebula/genesis.key
```

Commit `*.crt` files (public) to the repo.
Do NOT commit raw `*.key` files — encrypt them first (Step 4).

## Step 4 — Encrypt private keys with agenix

From the repo root:
```bash
cd nixos
for host in linode genesis hosea isaiah jeremiah zeke exodus; do
  agenix -e secrets/nebula/${host}.key.age < secrets/nebula/${host}.key
  rm secrets/nebula/${host}.key   # remove plaintext key
done
```

The `secrets/secrets.nix` file already declares the `.key.age` recipients.

## Step 5 — Configure linode's public DNS / firewall

- Add a DNS A record: `linode.nebula.thehellings.com` → linode's public IP
- Open UDP port `4242` in linode's firewall / Linode Cloud Firewall rules

## Step 6 — Deploy

```bash
colmena apply --on linode   # lighthouse first
colmena apply               # rest of the fleet
```

## Verifying

```bash
# From any host, ping another by Nebula IP
ping 10.157.0.2   # genesis

# From any host, reach home LAN via unsafe_routes
ping 10.42.1.1    # UDM Pro (via genesis)
```

## Notes

- `ca.crt` is public and lives in the repo unencrypted.
- `*.crt` (host certs) are public and live in the repo unencrypted.
- `*.key.age` are agenix-encrypted private keys (in `secrets/nebula/`).
- The NixOS module (`modules/nixos/nebula.nix`) references these paths directly.
- The lighthouse (`linode`) has `isLighthouse = true` and `isRelay = true`.
- `genesis` has `routesSubnet = "10.42.0.0/16"` which enables IP forwarding
  and nftables masquerade so Nebula peers can reach the home LAN.
- All other hosts have `unsafeRoutes` pointing to genesis (10.157.0.2) for
  the 10.42.0.0/16 subnet.
