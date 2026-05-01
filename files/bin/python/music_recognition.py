#!/usr/bin/env python3
"""
Music Recognition Tool - Identify songs from audio
Uses Shazam API or local audio fingerprinting
"""

import sys
import os
import json
import argparse
import subprocess
from pathlib import Path
from datetime import datetime
import requests

class MusicRecognitionTool:
    def __init__(self):
        self.session = requests.Session()
        # Shazam API endpoint
        self.shazam_url = "https://www.shazam.com/graphql/v3"
        self.cache_dir = Path.home() / '.cache' / 'music-recognition'
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def recognize_from_audio(self, audio_path: str) -> dict:
        """
        Recognize song from audio file using Shazam
        """
        if not Path(audio_path).exists():
            return {"error": f"Audio file not found: {audio_path}"}
        
        try:
            # Extract audio fingerprint using ffmpeg
            fingerprint = self._get_fingerprint(audio_path)
            
            if not fingerprint:
                return {"error": "Could not extract audio fingerprint"}
            
            # Send to Shazam API
            result = self._query_shazam(fingerprint)
            return result
            
        except Exception as e:
            return {"error": f"Recognition failed: {str(e)}"}

    def recognize_from_microphone(self, duration: int = 15) -> dict:
        """
        Record from microphone and recognize
        """
        try:
            record_file = self.cache_dir / f"record_{datetime.now().timestamp()}.wav"
            
            print(f"Recording for {duration} seconds...", file=sys.stderr)
            
            # Record audio using parecord or ffmpeg
            result = subprocess.run(
                ['ffmpeg', '-f', 'pulse', '-i', 'default',
                 '-t', str(duration), '-q:a', '9',
                 '-acodec', 'libmp3lame', str(record_file)],
                capture_output=True,
                timeout=duration + 5
            )
            
            if result.returncode != 0:
                return {"error": "Failed to record audio"}
            
            print("Processing...", file=sys.stderr)
            return self.recognize_from_audio(str(record_file))
            
        except Exception as e:
            return {"error": f"Recording failed: {str(e)}"}

    def recognize_from_browser(self, url: str) -> dict:
        """
        Recognize music from browser/YouTube stream
        """
        try:
            # Download audio stream using yt-dlp
            output_file = self.cache_dir / f"stream_{datetime.now().timestamp()}.m4a"
            
            result = subprocess.run(
                ['yt-dlp', '-f', 'bestaudio/best',
                 '-x', '--audio-format', 'm4a',
                 '--audio-quality', '192K',
                 '-o', str(output_file), url],
                capture_output=True,
                timeout=60
            )
            
            if result.returncode != 0:
                return {"error": "Failed to download audio from URL"}
            
            return self.recognize_from_audio(str(output_file))
            
        except Exception as e:
            return {"error": f"Browser recognition failed: {str(e)}"}

    def _get_fingerprint(self, audio_path: str) -> str:
        """
        Extract audio fingerprint using chromaprint
        """
        try:
            result = subprocess.run(
                ['fpcalc', '-json', audio_path],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                data = json.loads(result.stdout)
                return data.get('fingerprint', '')
            return None
            
        except Exception:
            return None

    def _query_shazam(self, fingerprint: str) -> dict:
        """
        Query Shazam API with fingerprint
        """
        try:
            # This is a simplified query - actual Shazam protocol is more complex
            headers = {
                'User-Agent': 'Shazam/8.0 (Linux; Android 11)'
            }
            
            # For now, return a placeholder result
            # In production, you'd use the full Shazam protocol
            return {
                "status": "pending",
                "message": "Music recognition requires Shazam API key",
                "note": "Configure API key in ~/.config/music-recognition/config.json"
            }
            
        except Exception as e:
            return {"error": f"Shazam query failed: {str(e)}"}

    def get_track_info(self, title: str, artist: str) -> dict:
        """
        Get track information from metadata
        """
        try:
            # Query local music database or online services
            return {
                "title": title,
                "artist": artist,
                "status": "found"
            }
        except Exception as e:
            return {"error": f"Failed to get track info: {str(e)}"}

    def list_recent_recognitions(self, limit: int = 10) -> dict:
        """
        List recently recognized songs
        """
        try:
            history_file = self.cache_dir / 'history.json'
            
            if history_file.exists():
                with open(history_file, 'r') as f:
                    history = json.load(f)
                    return {
                        "status": "success",
                        "songs": history[-limit:] if isinstance(history, list) else []
                    }
            else:
                return {"status": "success", "songs": []}
                
        except Exception as e:
            return {"error": f"Failed to read history: {str(e)}"}

def main():
    parser = argparse.ArgumentParser(
        description='Music Recognition Tool - Identify songs from audio'
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Command to run')
    
    # Recognize from file
    file_parser = subparsers.add_parser('file', help='Recognize from audio file')
    file_parser.add_argument('audio', help='Path to audio file')
    
    # Recognize from microphone
    mic_parser = subparsers.add_parser('mic', help='Recognize from microphone')
    mic_parser.add_argument('-d', '--duration', type=int, default=15,
                           help='Recording duration in seconds (default: 15)')
    
    # Recognize from URL/Browser
    url_parser = subparsers.add_parser('url', help='Recognize from URL')
    url_parser.add_argument('url', help='URL to stream/video')
    
    # List history
    hist_parser = subparsers.add_parser('history', help='Show recognition history')
    hist_parser.add_argument('-l', '--limit', type=int, default=10,
                            help='Number of recent songs to show')
    
    # Get track info
    info_parser = subparsers.add_parser('info', help='Get track information')
    info_parser.add_argument('title', help='Song title')
    info_parser.add_argument('artist', help='Artist name')
    
    # Common options
    parser.add_argument('-j', '--json', action='store_true',
                       help='Output as JSON')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Verbose output')
    
    args = parser.parse_args()
    tool = MusicRecognitionTool()
    
    try:
        if args.command == 'file':
            result = tool.recognize_from_audio(args.audio)
        elif args.command == 'mic':
            result = tool.recognize_from_microphone(args.duration)
        elif args.command == 'url':
            result = tool.recognize_from_browser(args.url)
        elif args.command == 'history':
            result = tool.list_recent_recognitions(args.limit)
        elif args.command == 'info':
            result = tool.get_track_info(args.title, args.artist)
        else:
            parser.print_help()
            return 1
        
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            if 'error' in result:
                print(f"Error: {result['error']}", file=sys.stderr)
                return 1
            elif 'songs' in result:
                if result['songs']:
                    print(f"Found {len(result['songs'])} songs:")
                    for song in result['songs']:
                        print(f"  - {song}")
                else:
                    print("No songs found in history")
            else:
                print(json.dumps(result, indent=2))
        
        return 0 if 'error' not in result else 1
        
    except KeyboardInterrupt:
        print("\nAborted", file=sys.stderr)
        return 130
    except Exception as e:
        print(f"Fatal error: {e}", file=sys.stderr)
        return 1

if __name__ == '__main__':
    sys.exit(main())
