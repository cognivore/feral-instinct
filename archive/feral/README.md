# Archived: Feral Hosting VPN Support

This directory contains the original Feral Hosting VPN configuration scripts that have been deprecated in favor of the self-sovereign WireGuard mesh approach.

## Why Deprecated

The Feral Hosting VPN had persistent issues:

1. **Broken NAT routing**: The VPN server pushed `redirect-gateway def1` but lacked proper iptables MASQUERADE rules to forward VPN client traffic to the internet
2. **No user control**: As a shared hosting environment, users couldn't fix the server-side NAT configuration
3. **Unreliable connectivity**: VPN would connect but internet access would fail

## Archived Files

- `feral-vpn.ysh` - Main CLI for Feral VPN management
- `clean-reset.ysh` - Reset script for Feral configuration
- `remote.ysh` - SSH/SCP operations for Feral slot
- `local.ysh` - macOS/Tunnelblick configuration

## If You Still Want to Use Feral

These scripts may still work for split-tunnel mode (routing only Feral traffic through VPN). To enable this, you would need to add to the client config:

```
pull-filter ignore "redirect-gateway"
route 10.32.0.0 255.255.0.0 vpn_gateway
```

However, we recommend using the new WireGuard mesh approach instead.

