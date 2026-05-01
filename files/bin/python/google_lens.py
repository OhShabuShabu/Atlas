#!/usr/bin/env python3
"""
Google Lens Tool - Image Recognition and Search
Uses Google's reverse image search API to analyze images
"""

import sys
import os
import requests
import json
import argparse
from pathlib import Path
from urllib.parse import urljoin
import subprocess

class GoogleLensTool:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
        })
        self.base_url = "https://www.google.com"
        self.lens_url = "https://www.google.com/searchbyimage"

    def search_by_image(self, image_path: str, open_browser: bool = False) -> dict:
        """
        Search using image URL or file path
        Returns the Google Lens search URL
        """
        if not Path(image_path).exists():
            return {"error": f"Image file not found: {image_path}"}
        
        # Read and prepare image
        with open(image_path, 'rb') as img_file:
            files = {'encoded_image': (Path(image_path).name, img_file)}
            
            try:
                # Upload to Google Images
                response = self.session.post(
                    self.lens_url,
                    files=files,
                    allow_redirects=True,
                    timeout=10
                )
                
                search_url = response.url
                
                if open_browser:
                    subprocess.run(['xdg-open', search_url])
                
                return {
                    "status": "success",
                    "search_url": search_url,
                    "image_path": image_path
                }
                
            except Exception as e:
                return {"error": f"Search failed: {str(e)}"}

    def search_by_clipboard(self) -> dict:
        """
        Capture screenshot or use clipboard image
        """
        try:
            # Try to get image from clipboard
            result = subprocess.run(
                ['wl-paste', '--type', 'image/png'],
                capture_output=True,
                timeout=5
            )
            
            if result.returncode == 0:
                # Save clipboard image
                cache_dir = Path.home() / '.cache' / 'google-lens'
                cache_dir.mkdir(parents=True, exist_ok=True)
                
                image_path = cache_dir / 'clipboard.png'
                with open(image_path, 'wb') as f:
                    f.write(result.stdout)
                
                return self.search_by_image(str(image_path), open_browser=True)
            else:
                return {"error": "No image in clipboard"}
                
        except Exception as e:
            return {"error": f"Clipboard access failed: {str(e)}"}

    def analyze_image(self, image_path: str) -> dict:
        """
        Analyze image using local vision API (if available)
        or return metadata
        """
        if not Path(image_path).exists():
            return {"error": f"Image file not found: {image_path}"}
        
        try:
            # Get image metadata
            result = subprocess.run(
                ['identify', '-verbose', image_path],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0:
                return {
                    "status": "success",
                    "image_path": image_path,
                    "metadata": result.stdout
                }
            else:
                return {"error": "Failed to analyze image"}
                
        except Exception as e:
            return {"error": f"Analysis failed: {str(e)}"}

def main():
    parser = argparse.ArgumentParser(
        description='Google Lens Tool - Image Recognition and Search'
    )
    parser.add_argument(
        'image',
        nargs='?',
        help='Path to image file (omit to use clipboard)'
    )
    parser.add_argument(
        '-c', '--clipboard',
        action='store_true',
        help='Search using image from clipboard'
    )
    parser.add_argument(
        '-a', '--analyze',
        action='store_true',
        help='Analyze image metadata without searching'
    )
    parser.add_argument(
        '-b', '--browser',
        action='store_true',
        help='Open results in browser'
    )
    parser.add_argument(
        '-j', '--json',
        action='store_true',
        help='Output as JSON'
    )
    
    args = parser.parse_args()
    tool = GoogleLensTool()
    
    try:
        if args.clipboard or (not args.image and not args.analyze):
            result = tool.search_by_clipboard()
        elif args.analyze and args.image:
            result = tool.analyze_image(args.image)
        elif args.image:
            result = tool.search_by_image(args.image, open_browser=args.browser)
        else:
            parser.print_help()
            return 1
        
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            if 'error' in result:
                print(f"Error: {result['error']}", file=sys.stderr)
                return 1
            elif 'search_url' in result:
                print(f"Search URL: {result['search_url']}")
            elif 'metadata' in result:
                print(result['metadata'])
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
