# WireGuard Mesh

A self-sovereign, multi-geo WireGuard VPN mesh built with YSH (Oils shell) and passveil for secrets management. Features a beautiful TUI powered by [gum](https://github.com/charmbracelet/gum).

## Installation

### Option 1: Nix Profile (Recommended)

```bash
# Install directly from the flake
nix profile install github:cognivore/wireguard-mesh

# Then use commands directly:
wg-mesh wizard       # Setup wizard
wg-switch           # TUI route switcher
wg-connect          # Connect to VPN
wg-status           # Show status
```

### Option 2: Development Shell

```bash
git clone https://github.com/cognivore/wireguard-mesh.git
cd wireguard-mesh
nix develop         # or: direnv allow
ysh bin/wg-setup.ysh wizard
```

## Architecture

```
    ┌─────────────┐         ┌─────────────┐
    │ RamNode SEA │─────────│ RamNode NYC │
    │ (Seattle)   │    ╲    │ (New York)  │
    └──────┬──────┘     ╲   └──────┬──────┘
           │             ╲         │
           │              ╲        │
           │               ╲       │
    ┌──────┴──────┐    ┌────╲─────┴┐
    │ Flokinet FI │────│ Flokinet NL│
    │ (Finland)   │    │ (Netherlands)│
    └─────────────┘    └─────────────┘

     Up to 8 nodes, full mesh WireGuard tunnels
```

## Why This Exists

Instead of relying on a single VPN provider that may have:
- Broken NAT routing (looking at you, Feral)
- Overcrowded IP ranges that get blocked
- Limited geographic options

...this project lets you build your own multi-geo VPN mesh using privacy-friendly VPS providers.

## Features

- **Multi-geo**: US (Seattle, NYC, LA, Atlanta), EU (Netherlands, Romania), Nordic (Finland, Iceland)
- **Full mesh**: Every node connects to every other node
- **Privacy-first providers**: RamNode (US) and FlokiNET (EU/Nordic)
- **Beautiful TUI**: Interactive menus with arrow key navigation (powered by gum)
- **Automated setup**: Interactive wizard for account creation
- **Secrets management**: All credentials stored in passveil
- **Split or full tunnel**: Route all traffic or just mesh traffic
- **Quick route switching**: TUI to instantly switch between VPN nodes
- **Nix-installable**: Install once, use anywhere (`nix profile install`)

## Prerequisites

- [Nix package manager](https://nixos.org/download.html) with flakes enabled
- SSH key pair for server access
- Accounts at VPS providers (wizard helps set these up)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/cognivore/wireguard-mesh.git
cd wireguard-mesh

# Enter the Nix development environment
nix develop
# Or with direnv: direnv allow

# Run the setup wizard
ysh bin/wg-setup.ysh wizard
```

## Workflow

### 1. Account Setup

```bash
ysh bin/wg-setup.ysh wizard
```

The wizard will:
1. Open browser to provider signup pages
2. Generate secure passwords via passveil
3. Guide you through setting up your accounts

### 2. VPS Provisioning

```bash
ysh bin/wg-setup.ysh provision
```

Guides you through ordering VPS instances at:
- **RamNode**: Seattle, NYC, LA, Atlanta (US)
- **FlokiNET**: Finland, Netherlands, Iceland, Romania

### 3. WireGuard Setup

```bash
# Install WireGuard on all nodes
ysh bin/wg-setup.ysh setup-wg

# Deploy mesh configuration
ysh bin/wg-setup.ysh deploy

# Add your client to the mesh
ysh bin/wg-setup.ysh add-client
```

### 4. Connect!

```bash
# TUI route switcher (recommended!)
ysh bin/wg-switch.ysh

# Or connect directly to default node
ysh bin/wg-connect.ysh

# Connect to specific node
ysh bin/wg-connect.ysh ramnode-sea

# Split tunnel (only mesh traffic through VPN)
ysh bin/wg-connect.ysh --split flokinet-fi

# Check status
ysh bin/wg-status.ysh
```

### 5. Switch Routes on the Fly

Use the TUI route switcher to quickly change which node you're routing through:

```bash
ysh bin/wg-switch.ysh
```

This opens an interactive menu where you can:
- See all available nodes with status indicators
- Select a node with arrow keys
- Instantly switch your connection

## Commands Reference

### Setup Commands

| Command | Description |
|---------|-------------|
| `wg-setup.ysh wizard` | Interactive account setup |
| `wg-setup.ysh status` | Show configuration status |
| `wg-setup.ysh provision` | Create VPS instances |
| `wg-setup.ysh setup-wg` | Install WireGuard on nodes |
| `wg-setup.ysh deploy` | Deploy mesh configuration |
| `wg-setup.ysh add-client` | Add local client to mesh |
| `wg-setup.ysh teardown` | Clean up everything |

### Connection Commands

| Command | Description |
|---------|-------------|
| `wg-switch.ysh` | **TUI route switcher** - interactive node selection |
| `wg-switch.ysh --quick` | Quick switch to last/first available node |
| `wg-connect.ysh` | Connect to default node |
| `wg-connect.ysh <node>` | Connect to specific node |
| `wg-connect.ysh --list` | List available nodes |
| `wg-connect.ysh --disconnect` | Disconnect from VPN |
| `wg-connect.ysh --split <node>` | Split tunnel mode |
| `wg-status.ysh` | Show detailed mesh status |

### Migration Commands

| Command | Description |
|---------|-------------|
| `uninstall-tunnelblick.ysh` | Completely remove Tunnelblick |
| `uninstall-tunnelblick.ysh --force` | Non-interactive removal |
| `uninstall-tunnelblick.ysh --dry-run` | Show what would be removed |

### Diagnostic Commands

| Command | Description |
|---------|-------------|
| `wg-setup.ysh mesh-status` | Show all node statuses |
| `wg-setup.ysh test-mesh` | Test connectivity between nodes |
| `wg-setup.ysh gen-client` | Generate client config file |

## File Structure

```
wireguard-mesh/
├── bin/
│   ├── wg-setup.ysh              # Main setup CLI
│   ├── wg-connect.ysh            # Client connection manager
│   ├── wg-switch.ysh             # TUI route switcher
│   ├── wg-status.ysh             # Status dashboard
│   └── uninstall-tunnelblick.ysh # Tunnelblick removal script
├── lib/
│   ├── wizard.ysh        # Account setup wizard (with TUI)
│   ├── tui.ysh           # TUI components (gum wrappers)
│   ├── ramnode.ysh       # RamNode provisioning
│   ├── flokinet.ysh      # FlokiNET provisioning
│   ├── wireguard.ysh     # WireGuard config generation
│   └── passveil.ysh      # Passveil utilities
├── templates/
│   └── wg0.conf.template # WireGuard config template
├── archive/
│   └── feral/            # Deprecated Feral Hosting code
├── flake.nix             # Nix flake with packages
└── README.md
```

## Nix Package

The flake provides both a development shell and an installable package:

```bash
# Build the package
nix build

# Install to your profile
nix profile install .

# After installation, these commands are available:
wg-mesh                  # Main setup tool (alias for wg-setup)
wg-setup wizard         # Setup wizard
wg-connect              # Connect to VPN
wg-switch               # TUI route switcher
wg-status               # Show status
uninstall-tunnelblick   # Remove Tunnelblick
```

## Secrets Layout (passveil)

```
ramnode.com/
  └── user@email.com
      └── (password)
flokinet.is/
  └── user@email.com
      └── (password)
wireguard-mesh/
  ├── ramnode-sea/
  │   ├── ip
  │   ├── root-password
  │   ├── wg-private-key
  │   └── wg-public-key
  ├── ramnode-nyc/
  │   └── ...
  ├── flokinet-fi/
  │   └── ...
  ├── flokinet-nl/
  │   └── ...
  └── client/
      ├── wg-private-key
      └── wg-public-key
```

## Provider Notes

### RamNode

- **Website**: https://ramnode.com
- **Locations**: Seattle, NYC, Los Angeles, Atlanta, Amsterdam
- **Pros**: Independent since 2012, KVM VPS, unmetered bandwidth, torrent-friendly
- **Plans**: From ~$5/mo for 1GB RAM
- **Payment**: Card, PayPal, crypto

### FlokiNET

- **Website**: https://flokinet.is
- **Locations**: Finland, Netherlands, Iceland, Romania
- **Pros**: Privacy-focused, DMCA-ignored, offshore options
- **Payment**: Card, PayPal, crypto (BTC, XMR)

## Mesh Network Details

- **Subnet**: 10.100.0.0/24
- **Port**: 51820/UDP
- **Topology**: Full mesh (every node peers with every other)

### Node IPs

| Node | Internal IP | Location |
|------|-------------|----------|
| ramnode-sea | 10.100.0.1 | Seattle, US |
| ramnode-nyc | 10.100.0.2 | New York, US |
| ramnode-la | 10.100.0.3 | Los Angeles, US |
| ramnode-atl | 10.100.0.4 | Atlanta, US |
| flokinet-fi | 10.100.0.5 | Finland |
| flokinet-nl | 10.100.0.6 | Netherlands |
| flokinet-is | 10.100.0.7 | Iceland |
| flokinet-ro | 10.100.0.8 | Romania |
| client | 10.100.0.100 | Your machine |

## Troubleshooting

### Connection Issues

```bash
# Check if WireGuard is running
sudo wg show

# Test connectivity to mesh nodes
ysh bin/wg-setup.ysh test-mesh

# Check your public IP
curl https://ifconfig.me
```

### DNS Issues

If DNS doesn't work after connecting:
```bash
# The client config uses 1.1.1.1 and 8.8.8.8
# You can edit ~/.config/wireguard-mesh/wg-mesh.conf to change DNS
```

### Node Not Responding

1. Check the node is running: `ysh bin/wg-setup.ysh mesh-status`
2. SSH to the node and check WireGuard: `sudo wg show`
3. Restart WireGuard: `sudo systemctl restart wg-quick@wg0`

## Security Considerations

- All private keys are stored in passveil (GPG-encrypted)
- SSH keys should use Ed25519 or RSA 4096-bit
- Change root passwords after initial setup
- Consider disabling password authentication on VPS

## License

MIT

---

## Legacy: Feral Hosting Support

This project originally supported Feral Hosting VPN. That code has been archived in the `archive/feral/` directory. The Feral VPN had persistent issues with NAT routing that made it unreliable for full-tunnel VPN usage.
