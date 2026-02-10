#!/bin/bash

echo "🧪 Final Test of Arch Linux Install Script"
echo "=========================================="

# Run a complete test with developer preset
echo "📝 Running install.sh with developer preset selection..."

# Create expected output (developer preset should have base, terminal, dev, fonts, wm)
echo -e "\n2\ny\ny\ny\ny\ny\ny\ny\ny\ny\n" | timeout 60s ./install.sh

echo
echo "🔍 Checking results..."

# Find the most recent temp directory
TEMP_DIR=$(ls -1d /tmp/arch-install-* 2>/dev/null | head -1)

if [ -n "$TEMP_DIR" ] && [ -f "$TEMP_DIR/manifest.json" ]; then
    echo "✅ SUCCESS: Manifest created at $TEMP_DIR/manifest.json"
    echo
    echo "📋 Manifest content:"
    cat "$TEMP_DIR/manifest.json"
    echo
    
    # Validate manifest structure
    if command -v jq >/dev/null 2>&1; then
        echo "🔍 Validating JSON structure..."
        if jq empty "$TEMP_DIR/manifest.json" 2>/dev/null; then
            echo "✅ JSON is valid"
        else
            echo "❌ JSON validation failed"
        fi
    fi
    
    # Check if we got expected categories for developer preset
    if grep -q '"categories"' "$TEMP_DIR/manifest.json"; then
        echo "✅ Categories field present"
    else
        echo "❌ Categories field missing"
    fi
    
else
    echo "❌ FAILED: No manifest found"
    if [ -n "$TEMP_DIR" ]; then
        echo "Temp directory exists: $TEMP_DIR"
        ls -la "$TEMP_DIR"
    else
        echo "No temp directory found"
    fi
fi

echo
echo "🎯 Test completed!"