"""Reuse GitHub CLI credentials without putting tokens in logs or process arguments."""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def main():
    if not shutil.which("gh"):
        print("GitHub CLI unavailable; using existing Rokit authentication.")
        return

    preference = subprocess.run(
        ["git", "config", "--get", "harness.githubUser"],
        capture_output=True,
        text=True,
        check=False,
    )
    user = os.environ.get("ROKIT_GITHUB_USER") or preference.stdout.strip()
    arguments = ["gh", "auth", "token", "--hostname", "github.com"]
    if user:
        arguments.extend(["--user", user])
    result = subprocess.run(
        arguments,
        capture_output=True,
        text=True,
        check=False,
    )
    token = result.stdout.strip()
    if result.returncode or not token:
        print("Selected GitHub CLI authentication unavailable; using existing Rokit authentication.")
        return

    root = Path(os.environ.get("ROKIT_ROOT", Path.home() / ".rokit"))
    root.mkdir(parents=True, exist_ok=True)
    target = root / "auth.toml"
    content = target.read_text() if target.exists() else ""
    # Rokit 1.2 reads auth.toml, not GH_TOKEN/GITHUB_TOKEN. Preserve other entries.
    entry = "github = " + json.dumps(token)
    if re.search(r"^\s*github\s*=", content, flags=re.MULTILINE):
        content = re.sub(r"^\s*github\s*=.*$", lambda _: entry, content, flags=re.MULTILINE)
    else:
        content = content.rstrip() + "\n" + entry + "\n"

    descriptor, temporary = tempfile.mkstemp(dir=root, prefix=".auth-")
    try:
        with os.fdopen(descriptor, "w") as stream:
            stream.write(content)
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print("Rokit authentication refreshed from GitHub CLI (credentials hidden).")


if __name__ == "__main__":
    main()
