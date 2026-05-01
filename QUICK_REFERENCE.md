## Google Lens & Music Recognition Tools - Quick Reference

### 🔍 Google Lens Tool

**Installation:**
```bash
# Already integrated in your NixOS config
# Just rebuild to enable
sudo nixos-rebuild switch --flake .#atlas
```

**Quick Commands:**
```bash
# Search an image
google-lens photo.jpg

# Search from clipboard
google-lens -c

# Open results in browser
google-lens photo.jpg -b

# Analyze image metadata
google-lens photo.jpg -a

# JSON output for scripts
google-lens photo.jpg -j
```

**Script Location:** `/home/yusa/Atlas/files/bin/python/google_lens.py`
**Shell Wrapper:** `/home/yusa/Atlas/files/bin/shell/google-lens`

---

### 🎵 Music Recognition Tool

**Quick Commands:**
```bash
# Recognize from file
music-recognition file song.mp3

# Record and recognize from microphone
music-recognition mic              # 15 seconds
music-recognition mic -d 30        # 30 seconds

# Recognize from URL
music-recognition url https://youtube.com/watch?v=...

# View history
music-recognition history

# Get track info
music-recognition info "Title" "Artist"
```

**Script Location:** `/home/yusa/Atlas/files/bin/python/music_recognition.py`
**Shell Wrapper:** `/home/yusa/Atlas/files/bin/shell/music-recognition`

---

### 📋 Files Created

```
/home/yusa/Atlas/
├── files/
│   ├── bin/
│   │   ├── python/
│   │   │   ├── google_lens.py         (5.7 KB)
│   │   │   └── music_recognition.py   (8.7 KB)
│   │   └── shell/
│   │       ├── google-lens            (wrapper)
│   │       └── music-recognition      (wrapper)
│   └── modules/
│       └── tools.nix                  (1.8 KB)
├── files/core/
│   └── home.nix                       (UPDATED - added tools module)
└── TOOLS.md                           (documentation)
```

---

### 🔧 System Integration

**Module:** `files/modules/tools.nix`
- Installs all dependencies
- Configures ~/.config directories
- Sets up ~/.local/bin symlinks

**Dependencies Installed:**
- Python 3 + requests
- ImageMagick (image analysis)
- ffmpeg + chromaprint (audio)
- yt-dlp (URL downloads)
- wl-clipboard (Wayland clipboard)

---

### 📚 Full Documentation

See `TOOLS.md` for comprehensive usage guide, examples, and troubleshooting.

---

### ✅ Next Steps

1. **Rebuild your system:**
   ```bash
   sudo nixos-rebuild switch --flake .#atlas
   ```

2. **Verify installation:**
   ```bash
   which google-lens
   which music-recognition
   python3 ~/.local/bin/google_lens.py --help
   python3 ~/.local/bin/music_recognition.py --help
   ```

3. **Try it out:**
   ```bash
   # Test Google Lens with a sample image
   google-lens ~/Pictures/screenshot.png -b

   # Test Music Recognition
   music-recognition mic -d 10
   ```

4. **Optional: Add keyboard shortcuts**
   - Edit `~/.config/niri/config.kdl`
   - Add: `bind "Super+L" "google-lens -c"`
   - Add: `bind "Super+M" "kitty music-recognition mic -d 15"`

---

### 🐛 Troubleshooting

**Tools not found after rebuild:**
- Ensure `~/.local/bin` is in PATH: `echo $PATH`
- Log out and back in
- Check: `cat ~/.config/nushell/shellrc.nu`

**Dependencies missing:**
- Verify packages installed: `nix-shell -p imagemagick ffmpeg chromaprint`
- Rebuild: `sudo nixos-rebuild switch --flake .#atlas`

**For more help:**
- See comprehensive `TOOLS.md`
- Check script help: `google-lens --help`
- Check script help: `music-recognition --help`
