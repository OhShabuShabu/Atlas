# Google Lens Tool - Usage Guide

## Overview
A powerful image recognition and reverse image search tool integrated with your NixOS environment. Quickly identify objects, text, and scenes from images.

## Installation
The tools are installed as part of the NixOS configuration. Rebuild your system to enable:
```bash
sudo nixos-rebuild switch --flake .#atlas
```

## Usage

### Basic Image Search
Search an image file:
```bash
google-lens /path/to/image.jpg
```

### From Clipboard
Capture and search an image from your clipboard:
```bash
google-lens -c
google-lens --clipboard
```

### Open Results in Browser
Automatically open the Google Lens results in your browser:
```bash
google-lens image.png -b
google-lens image.png --browser
```

### Analyze Image Metadata
Extract detailed metadata from an image without searching:
```bash
google-lens image.jpg -a
google-lens image.jpg --analyze
```

### JSON Output
Get results in JSON format for scripting:
```bash
google-lens image.jpg -j
google-lens image.jpg --json
```

## Examples

### Search a screenshot for objects
```bash
scrot /tmp/screenshot.png
google-lens /tmp/screenshot.png -b
```

### Identify plants from photos
```bash
google-lens ~/photos/plant.jpg -b
```

### Extract text from images (OCR integration)
```bash
google-lens document.jpg --analyze
```

### Automate batch image searches
```bash
for img in ~/images/*.jpg; do
  google-lens "$img" -j | jq '.search_url'
done
```

## Configuration
Configuration file: `~/.config/google-lens/config.json`

Default settings:
- Browser: librewolf
- Cache directory: ~/.cache/google-lens
- Auto-open results: disabled

## Requirements
- `imagemagick` - Image analysis
- `wl-clipboard` - Clipboard integration (Wayland)
- `xdg-utils` - Browser integration
- Python 3 with requests library

## Tips & Tricks

### Create keyboard shortcut
Add to your Niri config:
```kdl
bind "Super+L" "google-lens --clipboard"
```

### Combine with other tools
```bash
# Search web for similar images
screenshot=$(scrot -o)
google-lens "$screenshot" -b

# Analyze and save results
google-lens photo.jpg -j | tee ~/lens-results.json
```

### Troubleshooting

**"Image file not found"**
- Verify the file path exists
- Check file permissions

**"No image in clipboard"**
- Ensure you've copied an image to clipboard
- Try: `scrot | wl-copy`

**Browser not opening**
- Verify xdg-open is working: `xdg-open https://google.com`
- Set default browser: `xdg-settings set default-web-browser librewolf.desktop`

---

# Music Recognition Tool - Usage Guide

## Overview
Identify songs and music tracks from audio files, microphone recordings, or streaming URLs. Features audio fingerprinting and music database integration.

## Installation
Installed as part of NixOS configuration. Rebuild to enable:
```bash
sudo nixos-rebuild switch --flake .#atlas
```

## Usage

### Recognize from Audio File
```bash
music-recognition file ~/Downloads/song.mp3
music-recognition file /path/to/audio.wav
```

### Record from Microphone
Record and recognize in one command:
```bash
music-recognition mic                    # 15 seconds (default)
music-recognition mic -d 30              # 30 seconds
music-recognition mic --duration 60      # 60 seconds
```

### Recognize from URL/Stream
```bash
music-recognition url "https://www.youtube.com/watch?v=..."
music-recognition url "https://soundcloud.com/..."
```

### View Recognition History
```bash
music-recognition history                # Last 10 songs
music-recognition history -l 20          # Last 20 songs
music-recognition history --limit 50     # Last 50 songs
```

### Get Track Information
```bash
music-recognition info "Song Title" "Artist Name"
```

### JSON Output
```bash
music-recognition file song.mp3 -j
music-recognition file song.mp3 --json
```

### Verbose Mode
```bash
music-recognition file song.mp3 -v
music-recognition file song.mp3 --verbose
```

## Examples

### Identify a song playing on your system
```bash
# Record 15 seconds from your speakers
music-recognition mic

# Or from microphone
music-recognition mic -d 20
```

### Bulk recognize multiple files
```bash
for audio in ~/music/*.mp3; do
  echo "Recognizing: $audio"
  music-recognition file "$audio" -j
done
```

### Stream recognition from YouTube
```bash
music-recognition url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

### Monitor audio and auto-recognize
```bash
# Create a script to watch a directory
watch -n 5 'music-recognition file ~/recordings/*.wav -j'
```

## Configuration
Configuration file: `~/.config/music-recognition/config.json`

Default settings:
- Shazam API key: (empty - set your own)
- Cache directory: ~/.cache/music-recognition
- Recording quality: high
- Recognition timeout: 30 seconds

To set Shazam API:
```bash
# Edit the config file
nano ~/.config/music-recognition/config.json

# Update: "shazam_api_key": "your_api_key_here"
```

## Requirements
- `ffmpeg` - Audio recording and conversion
- `chromaprint` - Audio fingerprinting
- `yt-dlp` - Download from URLs
- `sox` - Audio processing (optional)
- `mpv` - Audio playback (optional)
- Python 3 with requests library

## Audio Format Support
Supported formats:
- MP3, WAV, FLAC, OGG, M4A
- AAC, WMA, OPUS, and more via ffmpeg

## Tips & Tricks

### Create keyboard shortcut for quick recognition
Add to Niri config:
```kdl
bind "Super+M" "kitty music-recognition mic -d 15"
```

### Auto-save recognized songs
```bash
# Create a wrapper script
#!/bin/bash
result=$(music-recognition "$@" -j)
echo "$result" >> ~/.local/share/music-recognition/discovered.json
echo "$result" | jq -r '.title, .artist'
```

### Stream audio and recognize
```bash
# From PulseAudio
music-recognition mic -d 20

# From ALSA
ffmpeg -f alsa -i default -t 15 -q:a 9 -acodec libmp3lame ~/temp_recording.mp3
music-recognition file ~/temp_recording.mp3
```

### Integration with other tools
```bash
# Find song and open in browser
song=$(music-recognition file audio.mp3 -j | jq -r '.title')
xdg-open "https://www.youtube.com/results?search_query=$(echo $song | jq -sRr @uri)"
```

## Troubleshooting

**"Could not extract audio fingerprint"**
- File may be corrupted
- Try: `ffprobe audio.mp3` to verify
- Ensure chromaprint is installed

**Recording fails**
- Check PulseAudio: `pactl list sources`
- Try manual recording: `ffmpeg -f pulse -i default -t 15 output.wav`

**No results from Shazam**
- API key may be missing or expired
- Check: `cat ~/.config/music-recognition/config.json`

**"URL recognition failed"**
- Verify internet connection
- Check if yt-dlp works: `yt-dlp --version`
- Try: `yt-dlp https://youtu.be/...` manually

---

## Additional Resources

### Google Lens
- [Google Images](https://www.google.com/imghp)
- [Reverse Image Search Guide](https://support.google.com/images/answer/1866141)

### Music Recognition
- [MusicBrainz Database](https://musicbrainz.org/)
- [AcousticID](https://acousticid.org/)
- [Shazam API](https://developer.spotify.com/documentation/web-api)

### Related Commands
```bash
# Screenshot and search immediately
scrot - | wl-copy && google-lens -c

# Record and recognize music
ffmpeg -f pulse -i default -t 15 -q:a 9 -acodec libmp3lame /tmp/rec.mp3 && music-recognition file /tmp/rec.mp3

# Batch process images
find ~/images -type f -name "*.jpg" -exec google-lens {} -j \;
```

---

## Updates & Support
To update tools as part of system rebuild:
```bash
sudo nixos-rebuild switch --flake .#atlas --upgrade
```

For issues or enhancements, check your Atlas configuration directory.
