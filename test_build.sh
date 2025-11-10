#!/bin/bash
# Test script for Evilginx2 build and basic functionality
# This script verifies that the build works and phishlets are valid

set -e

echo "=================================="
echo "Evilginx2 Build and Test Script"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "1. Checking Go installation..."
if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    echo "   Found: $GO_VERSION"
    print_result 0 "Go is installed"
else
    print_result 1 "Go is not installed"
    exit 1
fi

echo ""
echo "2. Verifying Go version (1.22+ required)..."
GO_VERSION_NUM=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+' | head -1)
MAJOR=$(echo $GO_VERSION_NUM | cut -d. -f1)
MINOR=$(echo $GO_VERSION_NUM | cut -d. -f2)

if [ "$MAJOR" -ge 1 ] && [ "$MINOR" -ge 22 ]; then
    print_result 0 "Go version $GO_VERSION_NUM meets requirements"
else
    print_result 1 "Go version $GO_VERSION_NUM is too old (need 1.22+)"
fi

echo ""
echo "3. Checking required files..."
REQUIRED_FILES=("main.go" "go.mod" "go.sum" "phishlets/example.yaml")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_result 0 "Found $file"
    else
        print_result 1 "Missing $file"
    fi
done

echo ""
echo "4. Building Evilginx2..."
if go build -o evilginx main.go 2>&1; then
    print_result 0 "Build successful"
else
    print_result 1 "Build failed"
    exit 1
fi

echo ""
echo "5. Checking binary..."
if [ -f "./evilginx" ]; then
    SIZE=$(du -h ./evilginx | cut -f1)
    echo "   Binary size: $SIZE"
    print_result 0 "Binary exists"
else
    print_result 1 "Binary not found"
    exit 1
fi

echo ""
echo "6. Testing version flag..."
if ./evilginx -v 2>&1 | grep -q "version:"; then
    VERSION=$(./evilginx -v 2>&1 | grep "version:" | awk '{print $3}')
    echo "   Version: $VERSION"
    print_result 0 "Version flag works"
else
    print_result 1 "Version flag failed"
fi

echo ""
echo "7. Validating phishlet files..."
PHISHLET_DIR="./phishlets"
if [ -d "$PHISHLET_DIR" ]; then
    PHISHLET_COUNT=$(find "$PHISHLET_DIR" -name "*.yaml" | wc -l)
    echo "   Found $PHISHLET_COUNT phishlet(s)"
    print_result 0 "Phishlets directory exists with $PHISHLET_COUNT file(s)"
    
    # Check each phishlet for basic YAML validity
    for phishlet in "$PHISHLET_DIR"/*.yaml; do
        if [ -f "$phishlet" ]; then
            filename=$(basename "$phishlet")
            # Basic check for required fields
            if grep -q "min_ver:" "$phishlet" && grep -q "proxy_hosts:" "$phishlet"; then
                print_result 0 "Phishlet $filename has required fields"
            else
                print_result 1 "Phishlet $filename missing required fields"
            fi
        fi
    done
else
    print_result 1 "Phishlets directory not found"
fi

echo ""
echo "8. Checking documentation files..."
DOC_FILES=("README.md" "INSTALL.md" "COMMANDS.md" "CUSTOMIZATION.md" "QUICKSTART.md")
for doc in "${DOC_FILES[@]}"; do
    if [ -f "$doc" ]; then
        LINES=$(wc -l < "$doc")
        echo "   $doc: $LINES lines"
        print_result 0 "Documentation file $doc exists"
    else
        print_result 1 "Documentation file $doc missing"
    fi
done

echo ""
echo "9. Checking Tor availability (optional)..."
if command -v tor &> /dev/null; then
    TOR_VERSION=$(tor --version | head -1)
    echo "   Found: $TOR_VERSION"
    print_result 0 "Tor is installed"
    
    # Check if Tor is running
    if netstat -tlnp 2>/dev/null | grep -q ":9050" || ss -tlnp 2>/dev/null | grep -q ":9050"; then
        print_result 0 "Tor SOCKS proxy is listening on port 9050"
    else
        echo -e "${YELLOW}   Note: Tor is installed but not running on port 9050${NC}"
        echo "   Start it with: sudo systemctl start tor"
    fi
else
    echo -e "${YELLOW}   Tor not found - Optional for .onion support${NC}"
    echo "   Install it with: sudo apt-get install tor"
fi

echo ""
echo "10. Cleaning up test artifacts..."
if [ -f "./evilginx" ]; then
    rm ./evilginx
    print_result 0 "Cleaned up test binary"
fi

echo ""
echo "=================================="
echo "Test Summary"
echo "=================================="
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
else
    echo -e "${GREEN}Tests Failed: $TESTS_FAILED${NC}"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Read QUICKSTART.md for a 5-minute setup"
    echo "  2. Read INSTALL.md for detailed installation"
    echo "  3. Configure Tor if you need .onion support"
    echo "  4. Run: ./evilginx -p ./phishlets"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review the errors above.${NC}"
    exit 1
fi
