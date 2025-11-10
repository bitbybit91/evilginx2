# Evilginx2 Installation Guide

This guide provides step-by-step instructions for installing Evilginx2 with full support for v3 Onion addresses via Tor.

## Table of Contents
- [System Requirements](#system-requirements)
- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
  - [Method 1: Building from Source (Recommended)](#method-1-building-from-source-recommended)
  - [Method 2: Using Pre-built Binaries](#method-2-using-pre-built-binaries)
- [Tor Installation and Configuration](#tor-installation-and-configuration)
- [Post-Installation Setup](#post-installation-setup)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## System Requirements

- **Operating System**: Linux (Ubuntu 20.04+, Debian 10+, CentOS 7+) or macOS
- **Memory**: Minimum 2GB RAM (4GB+ recommended)
- **Disk Space**: At least 500MB free space
- **Network**: Internet connection for certificate generation
- **Root/Sudo Access**: Required for binding to privileged ports (80, 443)

## Prerequisites

### Required Packages

#### For Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y git golang-go build-essential net-tools
```

#### For CentOS/RHEL:
```bash
sudo yum update
sudo yum install -y git golang make gcc net-tools
```

#### For macOS:
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required packages
brew install git go
```

### Go Version Requirements

Evilginx2 requires Go 1.22 or higher. Check your Go version:

```bash
go version
```

If you need to upgrade Go:

#### Ubuntu/Debian:
```bash
# Remove old Go version
sudo apt-get remove golang-go
sudo rm -rf /usr/local/go

# Download and install Go 1.22+ (check https://go.dev/dl/ for latest version)
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz

# Add to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

## Installation Methods

### Method 1: Building from Source (Recommended)

This method ensures you have the latest version with all features.

#### Step 1: Clone the Repository

```bash
# Create a directory for Evilginx2
mkdir -p ~/evilginx2
cd ~/evilginx2

# Clone the repository
git clone https://github.com/bitbybit91/evilginx2.git
cd evilginx2
```

#### Step 2: Install Go Dependencies

```bash
# Download and verify dependencies
go mod download
go mod verify
```

#### Step 3: Build the Binary

```bash
# Build for your current platform
go build -o evilginx main.go

# Make the binary executable
chmod +x evilginx
```

**Platform-specific builds:**

For Linux:
```bash
GOOS=linux GOARCH=amd64 go build -o evilginx main.go
```

For macOS:
```bash
GOOS=darwin GOARCH=amd64 go build -o evilginx main.go
```

For macOS (Apple Silicon):
```bash
GOOS=darwin GOARCH=arm64 go build -o evilginx main.go
```

#### Step 4: Optional - Install System-wide

```bash
# Copy binary to system path
sudo cp evilginx /usr/local/bin/

# Copy phishlets directory
sudo mkdir -p /usr/share/evilginx
sudo cp -r phishlets /usr/share/evilginx/
sudo cp -r redirectors /usr/share/evilginx/
```

### Method 2: Using Pre-built Binaries

If available, you can download pre-compiled binaries:

```bash
# Download the latest release (replace VERSION with actual version)
wget https://github.com/bitbybit91/evilginx2/releases/download/VERSION/evilginx2-linux-amd64.tar.gz

# Extract the archive
tar -xzf evilginx2-linux-amd64.tar.gz
cd evilginx2

# Make executable
chmod +x evilginx
```

## Tor Installation and Configuration

To use Evilginx2 with v3 Onion addresses, you need to install and configure Tor.

### Step 1: Install Tor

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y tor
```

#### CentOS/RHEL:
```bash
sudo yum install -y epel-release
sudo yum install -y tor
```

#### macOS:
```bash
brew install tor
```

### Step 2: Configure Tor for SOCKS5 Proxy

Edit the Tor configuration file:

```bash
# Ubuntu/Debian/CentOS
sudo nano /etc/tor/torrc

# macOS
nano /usr/local/etc/tor/torrc
```

Add or uncomment these lines:

```
# SOCKS5 proxy configuration
SOCKSPort 9050

# Optional: Control port for advanced users
#ControlPort 9051

# Optional: Onion service configuration
#HiddenServiceDir /var/lib/tor/hidden_service/
#HiddenServicePort 80 127.0.0.1:80
#HiddenServicePort 443 127.0.0.1:443
```

Save and exit (Ctrl+X, then Y, then Enter in nano).

### Step 3: Start Tor Service

#### Ubuntu/Debian/CentOS:
```bash
# Start Tor
sudo systemctl start tor

# Enable Tor to start on boot
sudo systemctl enable tor

# Check Tor status
sudo systemctl status tor
```

#### macOS:
```bash
# Start Tor
brew services start tor

# Or run in foreground for testing
tor
```

### Step 4: Verify Tor is Running

```bash
# Check if Tor SOCKS5 proxy is listening
netstat -tlnp | grep 9050

# Or use ss command
ss -tlnp | grep 9050

# Expected output: tcp   0   0 127.0.0.1:9050   0.0.0.0:*   LISTEN
```

### Step 5: Test Tor Connection

```bash
# Test using curl through Tor
curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/ | grep -i congratulations

# If working, you should see a congratulations message
```

## Post-Installation Setup

### Step 1: Create Configuration Directory

Evilginx2 will create this automatically on first run, but you can create it manually:

```bash
mkdir -p ~/.evilginx
chmod 700 ~/.evilginx
```

### Step 2: Prepare Phishlets Directory

If you built from source and didn't install system-wide:

```bash
# Create a phishlets directory in your working location
mkdir -p ~/evilginx2/evilginx2/phishlets

# Copy the example phishlet
cp phishlets/example.yaml ~/evilginx2/evilginx2/phishlets/
```

### Step 3: Set up DNS (for production use)

For production phishing campaigns, you'll need:

1. A registered domain name
2. DNS records pointing to your server's IP address
3. Proper A/AAAA records for all subdomains used in phishlets

**Note**: For testing with Tor onion addresses, DNS setup is not required.

## Verification

### Test Basic Installation

```bash
# Run Evilginx2 with version flag
./evilginx -v

# Expected output: version: 3.3.0
```

### Test with Phishlets Directory

```bash
# Run with phishlets directory specified
./evilginx -p ./phishlets

# You should see the Evilginx2 banner and terminal prompt
```

### Test Tor Integration

After starting Evilginx2, you can configure it to use Tor:

```bash
# In Evilginx2 terminal:
proxy socks5 127.0.0.1 9050
proxy on
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: "go: command not found"
**Solution**: Go is not installed or not in PATH. Follow the Go installation steps above.

#### Issue: "permission denied" when running evilginx
**Solution**: Make the binary executable:
```bash
chmod +x evilginx
```

#### Issue: "failed to list phishlets directory"
**Solution**: Specify the phishlets directory:
```bash
./evilginx -p /path/to/phishlets
```

#### Issue: "bind: permission denied" on ports 80/443
**Solution**: Run with sudo or use setcap:
```bash
# Option 1: Run with sudo
sudo ./evilginx -p ./phishlets

# Option 2: Grant capability to bind privileged ports (Linux only)
sudo setcap 'cap_net_bind_service=+ep' ./evilginx
./evilginx -p ./phishlets
```

#### Issue: Tor connection fails
**Solution**: 
1. Verify Tor is running: `systemctl status tor`
2. Check SOCKS proxy is listening: `netstat -tlnp | grep 9050`
3. Test Tor manually: `curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/`
4. Check Tor logs: `sudo journalctl -u tor -f`

#### Issue: "invalid proxy type selected"
**Solution**: Use one of the supported proxy types: `http`, `https`, `socks5`, or `socks5h`

#### Issue: Build fails with Go errors
**Solution**: 
1. Ensure Go version is 1.22+: `go version`
2. Clean and rebuild:
```bash
go clean
rm -rf go.mod go.sum
go mod init github.com/kgretzky/evilginx2
go mod tidy
go build -o evilginx main.go
```

#### Issue: Certificate generation fails
**Solution**: 
1. Ensure port 80 is accessible from the internet
2. Check firewall rules: `sudo ufw status` (Ubuntu) or `sudo firewall-cmd --list-all` (CentOS)
3. Verify domain DNS is correctly configured
4. For testing, use developer mode: `./evilginx -developer`

### Getting Help

- Check the main documentation: `README.md`
- Review command reference: `COMMANDS.md`
- Check customization guide: `CUSTOMIZATION.md`
- GitHub Issues: https://github.com/bitbybit91/evilginx2/issues
- Original project: https://github.com/kgretzky/evilginx2

### Security Notes

⚠️ **Important Security Considerations:**

1. **Legal Use Only**: Only use Evilginx2 for authorized penetration testing
2. **Keep Updated**: Regularly update to get security patches
3. **Secure Your Server**: Use firewall rules and keep your system updated
4. **Protect Credentials**: Never commit database files or configuration with sensitive data
5. **Tor Anonymity**: Using Tor doesn't make you completely anonymous. Understand operational security

## Next Steps

After successful installation:

1. Read the [Commands Guide](COMMANDS.md) to learn how to use Evilginx2
2. Read the [Customization Guide](CUSTOMIZATION.md) to create your own phishlets
3. Test in a controlled environment before production use
4. Set up proper monitoring and logging

---

**Last Updated**: 2025-11-10  
**Version**: 3.3.0
