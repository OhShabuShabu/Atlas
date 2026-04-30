# Sudo GUI - Graphical Authorization Dialog

## Overview
A PyQt6-based graphical dialog for sudo authorization on Wayland/X11 desktops. This replaces the terminal-based password prompt with an interactive GUI dialog.

## Features

✅ **Graphical Interface**
- Dark-themed PyQt6 dialog
- Clear display of requested command
- Safe "No" default button
- Accessible on Wayland and X11

✅ **Smart Caching**
- "Yes to all" option for the current session
- Automatic cleanup of dead process entries
- Secure file permissions (0600)

✅ **Security**
- Only shows dialog for terminal input
- Falls back to regular sudo for non-interactive use
- Validates all input arguments
- Secure cache file handling
- Proper error handling and reporting

✅ **Robustness**
- Checks for PyQt6 availability
- Validates graphical environment (DISPLAY/WAYLAND_DISPLAY)
- Graceful fallback to regular sudo
- Proper exit codes and error messages

## Files

### `sudo` (Bash wrapper)
- Intercepts sudo calls
- Launches PyQt6 dialog if in graphical environment
- Falls back to regular sudo if needed
- Uses nix-shell for PyQt6 dependencies

### `sudo_ask.py` (Python dialog)
- PyQt6-based authorization dialog
- Displays command being executed
- Manages session cache for "Yes to all"
- Handles user responses (Yes/No)

### `test_sudo_gui.sh` (Test script)
- Demonstrates sudo-gui functionality
- Tests with sample command
- Useful for debugging

## Installation

The sudo wrapper should be installed at `~/.local/bin/sudo` and comes before `/run/wrappers/bin/sudo` in PATH.

```bash
# Copy wrapper to local bin
cp files/core/config/sudo-gui/sudo ~/.local/bin/
chmod +x ~/.local/bin/sudo
```

## Usage

Simply use sudo normally:
```bash
sudo ls -la /root
```

If in a graphical environment with a TTY, you'll see a dialog. Otherwise, it falls back to regular sudo.

## Session Caching

The "Yes to all" dropdown allows approving all sudo requests in the current terminal session:

1. Click the dropdown arrow (▼) instead of Yes
2. All subsequent sudo calls in that terminal will be approved automatically
3. Cache is cleared when the process exits or is terminated

## Security Considerations

- Cache files are stored with restricted permissions (0600)
- Dead process entries are automatically cleaned from cache
- Dialog only appears for interactive terminal input
- Non-interactive sudo calls pass through directly
- All input is validated before use

## Fixes Applied

### v2 (Latest)
- ✅ Fixed hardcoded path reference to Atlas directory
- ✅ Proper $HOME expansion with SCRIPT_DIR
- ✅ Enhanced error handling in Python script
- ✅ Security improvements to cache file permissions
- ✅ Better validation of arguments and environment
- ✅ Improved test script with proper quoting
- ✅ Added comprehensive documentation

### v1
- Initial implementation with basic PyQt6 dialog
- TTY detection
- Process-based caching

## Known Limitations

- Requires PyQt6 (pulled via nix-shell)
- Only works in graphical environments
- Session cache is per-process (not shared across terminals)
- Wayland only sets QT_QPA_PLATFORM, X11 requires DISPLAY

## Troubleshooting

**Dialog doesn't appear:**
- Check DISPLAY or WAYLAND_DISPLAY is set
- Verify sudo_ask.py exists at expected location
- Check PyQt6 is available

**Cache not working:**
- Cache files are stored in `~/.local/share/sudo-gui/`
- Each terminal session has its own cache
- Cache is cleared on process exit

**Permission denied errors:**
- Verify ~/.local/bin/sudo is in PATH before /run/wrappers/bin/sudo
- Check script has execute permissions

## Future Improvements

- [ ] Support for multiple terminal instances sharing cache
- [ ] Configurable timeout for "Yes to all"
- [ ] Command filtering/whitelist support
- [ ] Audit logging for approved commands
- [ ] Password-based authentication support
