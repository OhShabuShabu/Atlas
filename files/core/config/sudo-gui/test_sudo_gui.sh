#!/usr/bin/env bash
# Test the sudo GUI with sample data
nix-shell -p python3Packages.pyqt6 --run "python3 $HOME/Atlas/files/core/config/sudo-gui/sudo_ask.py 'ls -la /root' $$ 'ls' "