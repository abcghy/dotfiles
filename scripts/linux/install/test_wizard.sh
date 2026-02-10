#!/bin/bash

echo "=== Testing Arch Linux Install Script ==="
echo

# Create a temp directory for this test
export TEMP_DIR=$(mktemp -d -t arch-install-test-XXXXX)
echo "Using TEMP_DIR: $TEMP_DIR"

# Test 1: Run install.sh with minimal selections
echo -e "\n2\n0\n" | timeout 30s ./install.sh
TEST1_RESULT=$?

echo "Test 1 result: $TEST1_RESULT"

# Check if manifest was created
if [ -f "$TEMP_DIR/manifest.json" ]; then
    echo "✓ Manifest created successfully"
    echo "Manifest content:"
    cat "$TEMP_DIR/manifest.json"
else
    echo "✗ No manifest created"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo
echo "=== Test Complete ==="