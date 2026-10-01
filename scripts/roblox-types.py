"""Provision checksum-pinned Roblox types; verification never downloads them."""

import hashlib
from pathlib import Path
import sys
import urllib.error
import urllib.request


REVISION = "0382dc76ca9b73df3c8e7c9cd85a8dd493cbd0ae"  # luau-lsp 1.70.1
SHA256 = "2857efa8245485f8c25c19c018ee1ef9b46afab4efd2ea70fc3257cd3faf7080"
URL = f"https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/{REVISION}/scripts/globalTypes.d.luau"
TARGET = Path(__file__).resolve().parent.parent / "build" / "globalTypes.d.luau"


def valid(data):
    return hashlib.sha256(data).hexdigest() == SHA256


def main():
    if TARGET.exists() and valid(TARGET.read_bytes()):
        return
    if "--check" in sys.argv:
        sys.exit("Missing or modified Roblox definitions; run ./scripts/bootstrap.sh")

    try:
        with urllib.request.urlopen(URL, timeout=30) as response:
            data = response.read()
    except (urllib.error.URLError, TimeoutError) as error:
        sys.exit(f"Cannot download Roblox definitions: {error}. Rerun ./scripts/bootstrap.sh")
    if not valid(data):
        sys.exit("Roblox definitions checksum mismatch; refusing download")
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_bytes(data)
    print("Installed checksum-pinned Roblox definitions (luau-lsp 1.70.1).")


if __name__ == "__main__":
    main()
