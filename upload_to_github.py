#!/usr/bin/env python3
"""
Direct GitHub API File Uploader for Apple-Linux-Suite
Uploads all repository files directly to GitHub without needing local git installation.
"""

import sys
import os
import glob
import base64
import urllib.request
import json

OWNER = "shreyastouih-ctrl"
REPO = "apple-linux-Suite"

def upload_file(token, rel_path, local_path):
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/contents/{rel_path.replace('\\', '/')}"
    
    with open(local_path, "rb") as f:
        content_bytes = f.read()
    
    content_b64 = base64.b64encode(content_bytes).decode('utf-8')
    
    # Check if file exists on GitHub to get SHA
    sha = None
    req_check = urllib.request.Request(url, headers={
        "Authorization": f"token {token}",
        "User-Agent": "Apple-Linux-Suite-Uploader"
    })
    try:
        with urllib.request.urlopen(req_check) as resp:
            data = json.loads(resp.read().decode())
            sha = data.get("sha")
    except Exception:
        pass
    
    payload = {
        "message": f"Upload {rel_path} via Apple-Linux-Suite Uploader",
        "content": content_b64,
        "branch": "main"
    }
    if sha:
        payload["sha"] = sha
        
    data_json = json.dumps(payload).encode('utf-8')
    req = urllib.request.Request(url, data=data_json, headers={
        "Authorization": f"token {token}",
        "Content-Type": "application/json",
        "User-Agent": "Apple-Linux-Suite-Uploader"
    }, method="PUT")
    
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"[SUCCESS] Uploaded: {rel_path}")
    except Exception as e:
        print(f"[ERROR] Failed to upload {rel_path}: {e}")

def main():
    token = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("GITHUB_TOKEN")
    if not token:
        print("Usage: python upload_to_github.py <YOUR_GITHUB_PERSONAL_ACCESS_TOKEN>")
        print("Or set GITHUB_TOKEN environment variable.")
        sys.exit(1)
        
    print(f"Uploading files to https://github.com/{OWNER}/{REPO}...")
    
    files = glob.glob("**/*", recursive=True)
    ignore = [".git", "scratch_test.py", "upload_to_github.py"]
    
    for f in sorted(files):
        if os.path.isfile(f) and not any(ig in f for ig in ignore):
            upload_file(token, f, f)

if __name__ == "__main__":
    main()
