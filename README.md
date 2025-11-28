# Feral Instinct

Automated VPN configuration for FeralHosting slots using YSH (Oils shell) and Tunnelblick on macOS.

## What This Does

This tool automates the entire process of setting up a VPN connection to your FeralHosting seedbox slot:

1. Downloads OpenVPN configuration from your FeralHosting slot
2. Patches deprecated OpenVPN options for modern Tunnelblick compatibility
3. Creates and installs a Tunnelblick configuration bundle
4. Manages VPN connections via command line

## Prerequisites

- macOS
- [Nix package manager](https://nixos.org/download.html) with flakes enabled
- A FeralHosting slot with SSH access
- OpenVPN enabled on your FeralHosting slot

## End-to-End Setup Guide

### Step 1: Purchase a FeralHosting Slot

1. Go to [feralhosting.com](https://www.feralhosting.com)
2. Choose a plan and complete purchase
3. Wait for your slot to be provisioned (usually takes a few minutes)
4. Note your slot details from the welcome email:
   - Server hostname (e.g., `styx.feralhosting.com`)
   - Username (e.g., `j`)

### Step 2: Enable OpenVPN on Your Slot

1. Log into the [FeralHosting Manager](https://www.feralhosting.com/manager/)
2. Navigate to your slot
3. Go to **Software** → **OpenVPN**
4. Click **Install** or **Enable**
5. Wait for installation to complete
6. The OpenVPN configuration will be created at `~/private/vpn/client.ovpn` on your slot

### Step 3: Set Up SSH Key Authentication

On your local Mac, set up passwordless SSH access to your slot:

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy your public key to the FeralHosting slot
ssh-copy-id USERNAME@SERVER.feralhosting.com

# Test the connection (should not ask for password)
ssh USERNAME@SERVER.feralhosting.com
```

Replace `USERNAME` and `SERVER` with your actual slot details.

### Step 4: Clone and Configure This Repository

```bash
# Clone the repository
git clone https://github.com/cognivore/feral-instinct.git
cd feral-instinct

# Allow direnv to load the Nix environment
direnv allow

# Wait for dependencies to install (first time takes a minute)
```

### Step 5: Update Configuration (if needed)

If your FeralHosting credentials differ from the defaults, edit `lib/remote.ysh`:

```ysh
const FERAL_HOST = 'YOUR_SERVER.feralhosting.com'
const FERAL_USER = 'YOUR_USERNAME'
```

### Step 6: Run Setup

```bash
# Run the VPN setup
ysh bin/feral-vpn.ysh setup
```

This will:
1. Connect to your FeralHosting slot via SSH
2. Download the OpenVPN configuration
3. Patch deprecated options (`ns-cert-type` → `remote-cert-tls`, `comp-lzo` → `compress`)
4. Install Tunnelblick (if not present)
5. Create and install the VPN configuration

**Accept the Tunnelblick prompts** when they appear.

### Step 7: Connect to VPN

```bash
# Connect to the VPN
ysh bin/feral-vpn.ysh connect

# Check status and verify your IP
ysh bin/feral-vpn.ysh status
```

## Commands

| Command | Description |
|---------|-------------|
| `ysh bin/feral-vpn.ysh setup` | Download configs and set up Tunnelblick |
| `ysh bin/feral-vpn.ysh connect` | Connect to the VPN |
| `ysh bin/feral-vpn.ysh disconnect` | Disconnect from the VPN |
| `ysh bin/feral-vpn.ysh status` | Show connection status and current IP |
| `ysh bin/feral-vpn.ysh check` | Check if VPN is configured on remote slot |
| `ysh bin/clean-reset.ysh` | Complete reset: terminate, clean, and reinstall |

## Clean Reset

If you need to start fresh (new slot, broken config, etc.):

```bash
ysh bin/clean-reset.ysh
```

This script:
1. Gracefully terminates Tunnelblick
2. Removes all local VPN configurations
3. Downloads fresh configs from FeralHosting
4. Patches and reinstalls everything
5. Verifies the connection works

## File Structure

```
feral-instinct/
├── bin/
│   ├── feral-vpn.ysh      # Main CLI tool
│   └── clean-reset.ysh    # Complete reset script
├── lib/
│   ├── remote.ysh         # SSH/SCP operations for FeralHosting
│   └── local.ysh          # macOS/Tunnelblick configuration
├── flake.nix              # Nix flake with dependencies
└── README.md              # This file
```

## Configuration Files

| Location | Description |
|----------|-------------|
| `~/.config/feral-instinct/vpn/` | Downloaded OpenVPN configs |
| `~/.config/feral-instinct/feral.tblk/` | Tunnelblick bundle |
| `~/.feral-instinct-backups/` | Backups of original configs |

## Troubleshooting

### SSH Connection Fails

```bash
# Test SSH connection manually
ssh USERNAME@SERVER.feralhosting.com

# If password is required, set up SSH keys:
ssh-copy-id USERNAME@SERVER.feralhosting.com
```

### OpenVPN Not Enabled

1. Log into [FeralHosting Manager](https://www.feralhosting.com/manager/)
2. Go to Software → OpenVPN → Install

### VPN Connects But No Internet

The FeralHosting VPN routes all traffic through their server. If you can't access the internet:
1. Check that the VPN is actually connected: `ysh bin/feral-vpn.ysh status`
2. Verify your IP changed to the FeralHosting server IP

### Tunnelblick Configuration Error

If you see errors about unknown extensions or deprecated options, run:

```bash
ysh bin/clean-reset.ysh
```

This will fetch fresh configs and apply all necessary patches.

### "comp-lzo" or "ns-cert-type" Warnings

These are automatically patched by this tool. If you still see warnings:
1. Run `ysh bin/clean-reset.ysh`
2. Or manually check `~/.config/feral-instinct/vpn/client.ovpn` for deprecated options

## Why YSH?

[YSH (Oils shell)](https://oils.pub/) is a modern shell language that:
- Has proper data structures (Lists, Dicts)
- Better error handling than bash
- Cleaner syntax for scripting
- JSON-compatible structured data

## License

MIT

