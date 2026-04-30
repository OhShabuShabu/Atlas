#!/usr/bin/env bash
# Test the sudo GUI with sample data
# This script demonstrates the sudo-gui functionality

set -euo pipefail

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# FIX: Use proper path references
PYTHON_SCRIPT="$SCRIPT_DIR/sudo_ask.py"

if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    echo "Error: sudo_ask.py not found at $PYTHON_SCRIPT"
    exit 1
fi

echo "Testing sudo GUI dialog..."
echo "Command: ls -la /root"
echo "Parent PID: $$"
echo ""

# FIX: Properly quote arguments to avoid shell expansion
nix-shell -p python3Packages.pyqt6 --run "
    export QT_QPA_PLATFORM=wayland
    export XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-\$HOME/.runtime}
    python3 '$PYTHON_SCRIPT' 'ls -la /root' \$\$ 'ls'
" || {
    echo "Test returned: $?"
}
