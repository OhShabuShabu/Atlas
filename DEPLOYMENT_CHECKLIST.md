# Deployment Checklist - Google Lens & Music Recognition Tools

## Pre-Deployment Verification

### ✅ Files Created and Verified

- [ ] `files/bin/python/google_lens.py` exists and is executable
- [ ] `files/bin/python/music_recognition.py` exists and is executable
- [ ] `files/bin/shell/google-lens` exists and is executable
- [ ] `files/bin/shell/music-recognition` exists and is executable
- [ ] `files/modules/tools.nix` exists
- [ ] `files/core/home.nix` has been updated with tools.nix import
- [ ] Documentation files created (TOOLS.md, QUICK_REFERENCE.md, IMPLEMENTATION.md)

### ✅ Content Verification

- [ ] Python scripts have proper shebang (`#!/usr/bin/env python3`)
- [ ] Python scripts are properly formatted
- [ ] Shell wrappers have correct paths
- [ ] NixOS module includes all required dependencies
- [ ] Configuration files are syntactically correct

## Deployment Steps

### Step 1: System Rebuild
```bash
sudo nixos-rebuild switch --flake .#atlas
```
- [ ] Command executed successfully
- [ ] No build errors
- [ ] System rebuilt without issues

### Step 2: Verify Installation
```bash
which google-lens
which music-recognition
```
- [ ] `google-lens` found in PATH
- [ ] `music-recognition` found in PATH
- [ ] Both scripts are executable

### Step 3: Dependency Verification
```bash
# Check core dependencies
python3 --version
requests-python --version

# Check Google Lens dependencies
identify --version
xdg-open --version

# Check Music Recognition dependencies
ffmpeg -version
chromaprint --version
yt-dlp --version
```
- [ ] All dependencies installed
- [ ] Versions are compatible

### Step 4: Basic Functionality Tests

#### Google Lens Tests
```bash
# Test help
google-lens --help
```
- [ ] Help text displays correctly

```bash
# Test with sample image (if available)
google-lens /path/to/image.jpg -j
```
- [ ] JSON output format is correct

#### Music Recognition Tests
```bash
# Test help
music-recognition --help
```
- [ ] Help text displays correctly

```bash
# Test file recognition (if audio file available)
music-recognition file /path/to/audio.mp3
```
- [ ] Tool runs without errors

### Step 5: Optional Configuration

#### Keyboard Shortcuts
```bash
# Edit Niri config
nano ~/.config/niri/config.kdl
```
Add these lines:
```kdl
bind "Super+L" "google-lens -c"
bind "Super+M" "kitty music-recognition mic -d 15"
```
- [ ] Added Google Lens shortcut (Super+L)
- [ ] Added Music Recognition shortcut (Super+M)
- [ ] Config file syntax is valid

#### Verify Config Directories
```bash
ls ~/.config/google-lens/config.json
ls ~/.config/music-recognition/config.json
```
- [ ] Config files exist
- [ ] Config files contain valid JSON

### Step 6: Advanced Testing (Optional)

#### Google Lens Advanced
```bash
# Clipboard test
scrot | wl-copy
google-lens -c
```
- [ ] Clipboard integration works
- [ ] Browser opens with results

#### Music Recognition Advanced
```bash
# Microphone test
music-recognition mic -d 15
```
- [ ] Recording starts and completes
- [ ] No audio errors

```bash
# URL test (if available)
music-recognition url "https://www.youtube.com/watch?v=..."
```
- [ ] URL processing works correctly

## Post-Deployment

### Documentation
- [ ] User has read `QUICK_REFERENCE.md`
- [ ] User has access to `TOOLS.md` for advanced usage
- [ ] User understands basic command syntax

### Performance
- [ ] Tools launch quickly
- [ ] No memory leaks or resource issues
- [ ] Clipboard operations responsive
- [ ] Audio recording smooth

### Troubleshooting
- [ ] Confirmed no errors in system logs: `journalctl -e`
- [ ] No missing dependencies reported
- [ ] All config files are writable

## Integration Verification

- [ ] Tools appear in command palette (if applicable)
- [ ] Path integration successful (`$PATH` includes ~/.local/bin)
- [ ] Shell integration working (nushell, bash, etc.)

## Git Repository

### Before Committing
- [ ] All changes reviewed with `git status`
- [ ] All new files are intentional
- [ ] No sensitive data in files
- [ ] No temporary files included

### Commit Process
```bash
git add TOOLS.md QUICK_REFERENCE.md IMPLEMENTATION.md
git add files/bin/python/google_lens.py files/bin/python/music_recognition.py
git add files/bin/shell/google-lens files/bin/shell/music-recognition
git add files/modules/tools.nix
git diff --staged              # Review changes
git commit -m "feat: add Google Lens and Music Recognition tools"
```
- [ ] All relevant files staged
- [ ] Commit message is clear and descriptive
- [ ] No build artifacts or cache files included

## Final Verification

- [ ] `google-lens --version` or help works
- [ ] `music-recognition --version` or help works
- [ ] Both tools respond to `-j` (JSON) flag
- [ ] Documentation is comprehensive and clear
- [ ] User understands how to use both tools

## Success Criteria

- ✅ Both tools are installed and accessible
- ✅ All dependencies are properly configured
- ✅ Tools launch without errors
- ✅ Basic functionality verified
- ✅ Documentation is complete and accessible
- ✅ Optional features (keyboard shortcuts) configured if desired
- ✅ System remains stable after deployment

## Troubleshooting During Deployment

If any step fails, refer to:
- TOOLS.md - Comprehensive troubleshooting section
- IMPLEMENTATION.md - Detailed implementation notes
- System logs: `journalctl -xe`
- Tool help: `google-lens --help` and `music-recognition --help`

## Sign-Off

Date: __________________
User: __________________
System: ________________
Status: ✅ Ready / ❌ Issues Found

Notes:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

