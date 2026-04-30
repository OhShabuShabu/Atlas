# Sudo-GUI Wrapper Testing Guide

## Current Status

✅ **Pre-Rebuild Verification Complete**
- Configuration files created and validated
- Wrapper scripts exist and are syntactically correct
- PyQt6 error handling implemented
- HOME directory PATH expansion fixed

❌ **Pending: Apply System Rebuild**
- Configuration has been committed but not yet applied to system
- Wrapper exists but not in current PATH (`~/.local/bin` not in `$PATH`)

## Testing Checklist

### Phase 1: Pre-Rebuild (✅ COMPLETE)

- [x] Nix configuration files exist
- [x] Nix files parse correctly
- [x] Wrapper scripts have valid syntax (bash + Python3)
- [x] Real sudo is available at `/run/wrappers/bin/sudo`
- [x] Python3 is available
- [x] DISPLAY environment variable is set
- [x] Cache directory can be created
- [x] Configuration imports are correct
- [x] Wrapper script structure is sound
- [x] Helper script has error handling

### Phase 2: System Rebuild (⏳ PENDING)

To proceed with testing, you need to rebuild the NixOS system:

```bash
sudo nixos-rebuild switch --flake /home/yusa/Atlas
```

This command will:
1. Evaluate the flake configuration
2. Download/build necessary packages:
   - `python3`
   - `python3Packages.pyqt6`
3. Update home-manager to deploy:
   - `~/.local/bin/sudo` (wrapper script)
   - `~/.local/bin/sudo_ask.py` (helper script)
4. Update system PATH configuration
5. Link `/etc/profiles/per-user/yusa/bin` to make `~/.local/bin` available

**Estimated time:** 5-15 minutes depending on cache

### Phase 3: Post-Rebuild Verification (⏳ PENDING)

After rebuild completes, **open a new shell session** and verify:

#### Test 3.1: Wrapper is Found First

```bash
which sudo
# Expected output: /home/yusa/.local/bin/sudo
```

#### Test 3.2: PATH Order is Correct

```bash
echo $PATH | tr ':' '\n' | head -10
# Expected: ~/.local/bin should appear near top, BEFORE /run/wrappers/bin
```

#### Test 3.3: Wrapper is Executable

```bash
ls -la ~/.local/bin/sudo
# Expected: -rwxr-xr-x (or similar with x permissions)
```

#### Test 3.4: Helper Script Exists

```bash
ls -la ~/.local/bin/sudo_ask.py
# Expected: file should exist and be readable
```

### Phase 4: Functional Testing (⏳ PENDING)

#### Test 4.1: GUI Dialog in Graphical Environment

**Prerequisites:** Must be in a graphical desktop (Wayland/X11)

```bash
sudo ls -la /root
```

**Expected Behavior:**
- A PyQt6 dialog window appears
- Dialog shows the command: `ls -la /root`
- Two buttons: "Yes" and "No"
- Also shows "Yes to all" checkbox
- Click "Yes" to proceed or "No" to deny

**If dialog appears:**
```
✅ GUI wrapper is working correctly
✅ PyQt6 is loaded successfully
✅ DISPLAY/WAYLAND_DISPLAY detection works
```

#### Test 4.2: Caching Works

Immediately after clicking "Yes to all" in Test 4.1, run:

```bash
sudo ls -la /root
```

**Expected Behavior:**
- NO dialog appears
- Command executes immediately
- Cache file exists at: `~/.local/share/sudo-gui/yes_to_all.json`

**If no dialog appears:**
```
✅ Caching mechanism works correctly
```

#### Test 4.3: Cache Cleanup

```bash
# Clear the cache
rm ~/.local/share/sudo-gui/yes_to_all.json

# Run sudo again
sudo ls -la /root
```

**Expected Behavior:**
- Dialog appears again (cache was cleared)

#### Test 4.4: Fallback in TTY

To test fallback behavior:

1. Switch to a virtual terminal:
   ```bash
   Ctrl+Alt+F2  # Switch to TTY2
   ```

2. Log in with your credentials

3. Run:
   ```bash
   sudo ls -la /root
   ```

**Expected Behavior:**
- NO GUI dialog appears
- Falls back to normal sudo password prompt
- Asks for password normally
- Works as standard sudo

**If fallback works:**
```
✅ TTY detection works correctly
✅ Non-graphical environment handling works
```

#### Test 4.5: Fallback When PyQt6 Unavailable

To simulate PyQt6 being unavailable:

```bash
# Temporarily rename the helper script
mv ~/.local/bin/sudo_ask.py ~/.local/bin/sudo_ask.py.bak

# Try sudo
sudo ls -la /root
# Should show error message or fallback

# Restore the script
mv ~/.local/bin/sudo_ask.py.bak ~/.local/bin/sudo_ask.py
```

**Expected Behavior:**
- Falls back to real sudo
- Shows error message or handles gracefully

#### Test 4.6: Permission Denial

```bash
sudo ls -la /root
# Click "No" in the dialog
```

**Expected Behavior:**
- Command does NOT execute
- Error message: `sudo: permission denied by user`

## Detailed Test Scenarios

### Scenario A: Full Happy Path

```bash
# In graphical environment
which sudo                          # ✅ /home/yusa/.local/bin/sudo
sudo touch /tmp/test-file           # ✅ Dialog appears
# Click "Yes to all"
sudo ls /tmp/test-file              # ✅ No dialog, uses cache
rm /tmp/test-file                   # Cleanup
```

### Scenario B: TTY Fallback

```bash
# In TTY (Ctrl+Alt+F2)
which sudo                          # ✅ /run/wrappers/bin/sudo
sudo ls -la /root                   # ✅ Normal password prompt
# Enter password
```

### Scenario C: Permission Denied

```bash
# In graphical environment
sudo touch /tmp/test-deny           # Dialog appears
# Click "No"
# ❌ Command denied
sudo ls /tmp/test-deny              # File doesn't exist
```

## Troubleshooting

### Issue: `which sudo` still shows `/run/wrappers/bin/sudo`

**Solution:**
1. Did the rebuild complete successfully?
   ```bash
   nixos-rebuild list-generations
   # Should show a new generation
   ```

2. Are you in a new shell session?
   ```bash
   exit  # Exit current shell
   # Open new terminal
   ```

3. Check if PATH includes `~/.local/bin`:
   ```bash
   echo $PATH | grep -o '/home/yusa/.local/bin' || echo "NOT IN PATH"
   ```

### Issue: GUI Dialog Doesn't Appear

**Check 1: Are we in a graphical environment?**
```bash
echo "DISPLAY=$DISPLAY"
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
# At least one should be set
```

**Check 2: Is PyQt6 available?**
```bash
python3 -c "from PyQt6.QtWidgets import QApplication; print('OK')"
```

**Check 3: Is the wrapper being executed?**
```bash
bash -x ~/.local/bin/sudo echo test 2>&1 | head -20
```

**Check 4: Does the wrapper detect graphical environment?**
```bash
[[ -n "$DISPLAY" ]] && echo "DISPLAY OK" || echo "NO DISPLAY"
[[ -n "$WAYLAND_DISPLAY" ]] && echo "WAYLAND OK" || echo "NO WAYLAND"
```

### Issue: Permission Denied But Should Have Access

**Check:** Is the real sudo working?
```bash
/run/wrappers/bin/sudo ls -la /root
# If this works, the wrapper might have an issue
```

### Issue: Wrapper Script Not Found

**Verify:**
```bash
ls -la ~/.local/bin/
# Should show both sudo and sudo_ask.py

cat ~/.local/bin/sudo | head -1
# Should show #!/usr/bin/env bash
```

## Configuration Files Modified

- `files/core/configuration.nix` - Added sudo-gui module import
- `files/core/home.nix` - Fixed PATH expansion in sessionPath
- `files/modules/sudo-gui.nix` - New module for PyQt6 and Python3
- `files/core/config/sudo-gui/sudo` - Bash wrapper (already existed)
- `files/core/config/sudo-gui/sudo_ask.py` - Python helper (already existed)

## Next Steps

1. **Apply the configuration:**
   ```bash
   sudo nixos-rebuild switch --flake /home/yusa/Atlas
   ```

2. **After rebuild completes:**
   ```bash
   exit  # Exit current shell
   # Open new terminal
   which sudo  # Verify
   ```

3. **Run functional tests:**
   - Test 4.1: GUI Dialog
   - Test 4.2: Caching
   - Test 4.4: TTY Fallback

4. **Report results** with output from each test

## Success Criteria

- ✅ `which sudo` returns `/home/yusa/.local/bin/sudo`
- ✅ GUI dialog appears when running sudo in graphical environment
- ✅ Dialog respects "Yes to all" caching
- ✅ Fallback works in TTY
- ✅ Permission denial works correctly

All criteria met = **Sudo-GUI wrapper is fully functional** ✅
