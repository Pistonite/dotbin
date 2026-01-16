#!/usr/bin/env python3
"""
Script to setup claudecode.nvim with custom patches.

This script:
1. Sparse clones the claudecode.nvim repo (lua/ and plugin/ directories only)
2. Applies local patches
3. Copies patched files to the nvim config
4. Cleans up the temporary repo
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

# Constants
REPO_URL = "https://github.com/coder/claudecode.nvim.git"
COMMIT_HASH = "93f8e48b1f6cbf2469b378c20b3df4115252d379"
LOCAL_REPO_PATH = Path("external/claudecode.nvim")
PATCH_FILE = Path("claudecode.patch")


def get_git_binary() -> str:
    """Find the git binary using shutil.which."""
    git_path = shutil.which("git")
    if git_path is None:
        print("Error: git binary not found in PATH", file=sys.stderr)
        sys.exit(1)
    return git_path


def run_git(*args: str, cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess:
    """Run a git command."""
    git = get_git_binary()
    cmd = [git, *args]
    return subprocess.run(cmd, cwd=cwd, check=check, capture_output=True, text=True)


def sparse_checkout_repo() -> None:
    """Perform sparse checkout of the repo."""
    LOCAL_REPO_PATH.parent.mkdir(parents=True, exist_ok=True)
    if LOCAL_REPO_PATH.exists():
        shutil.rmtree(LOCAL_REPO_PATH)
    print(f"Cloning {REPO_URL} (sparse checkout)...")
    LOCAL_REPO_PATH.mkdir(parents=True, exist_ok=True)
    run_git("init", cwd=LOCAL_REPO_PATH)
    run_git("remote", "add", "origin", REPO_URL, cwd=LOCAL_REPO_PATH)
    run_git("config", "core.sparseCheckout", "true", cwd=LOCAL_REPO_PATH)
    sparse_checkout_file = LOCAL_REPO_PATH / ".git" / "info" / "sparse-checkout"
    sparse_checkout_file.parent.mkdir(parents=True, exist_ok=True)
    sparse_checkout_file.write_text("lua/\nplugin/\n")
    print(f"Fetching commit {COMMIT_HASH}...")
    run_git("fetch", "--depth=1", "origin", COMMIT_HASH, cwd=LOCAL_REPO_PATH)
    run_git("checkout", COMMIT_HASH, cwd=LOCAL_REPO_PATH)
    print("Sparse checkout complete.")


def apply_patch() -> bool:
    """Apply the patch file. Returns True if successful, False if conflicts."""
    if not PATCH_FILE.exists():
        print(f"Warning: {PATCH_FILE} not found, skipping patch application.")
        return True
    # Convert CRLF to LF in patch file (Windows only)
    if sys.platform == "win32":
        content = PATCH_FILE.read_bytes()
        content = content.replace(b"\r\n", b"\n")
        PATCH_FILE.write_bytes(content)
        print(f"Converted {PATCH_FILE} to LF line endings.")
    print(f"Applying {PATCH_FILE}...")
    result = run_git("apply", "--3way", str(PATCH_FILE.absolute()), cwd=LOCAL_REPO_PATH, check=False)
    if result.returncode != 0:
        print("Patch application failed or has conflicts.", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        print("\nThe repo is left in an unmerged state at:", LOCAL_REPO_PATH)
        print("Please resolve the conflicts manually, then commit your changes.")
        print("After fixing, run this script with --repatch to generate a new patch file.")
        return False
    print("Patch applied successfully.")
    return True


def copy_local_to_repo() -> None:
    """Copy local lua/claudecode and plugin/claudecode.lua into the repo."""
    lua_src = Path("lua/claudecode")
    plugin_src = Path("plugin/claudecode.lua")
    lua_dest = LOCAL_REPO_PATH / "lua" / "claudecode"
    plugin_dest = LOCAL_REPO_PATH / "plugin" / "claudecode.lua"
    # Copy lua/claudecode directory
    if lua_src.exists():
        if lua_dest.exists():
            shutil.rmtree(lua_dest)
        shutil.copytree(lua_src, lua_dest)
        print(f"Copied {lua_src} -> {lua_dest}")
    else:
        print(f"Warning: {lua_src} not found", file=sys.stderr)
    # Copy plugin/claudecode.lua
    if plugin_src.exists():
        plugin_dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(plugin_src, plugin_dest)
        print(f"Copied {plugin_src} -> {plugin_dest}")
    else:
        print(f"Warning: {plugin_src} not found", file=sys.stderr)


def generate_repatch() -> None:
    """Generate a new patch from current state vs the original commit."""
    # If repo doesn't exist, create it and copy local files
    if not LOCAL_REPO_PATH.exists():
        print(f"{LOCAL_REPO_PATH} does not exist, creating it...")
        sparse_checkout_repo()
        copy_local_to_repo()
        # Commit the local changes so we can diff
        run_git("add", "-A", cwd=LOCAL_REPO_PATH)
        run_git("commit", "-m", "Local changes", cwd=LOCAL_REPO_PATH)
    print(f"Generating new patch (diff from {COMMIT_HASH} to HEAD)...")
    # Generate diff between the original commit and current HEAD
    result = run_git("diff", COMMIT_HASH, "HEAD", cwd=LOCAL_REPO_PATH)
    # Write the new patch file
    PATCH_FILE.write_text(result.stdout)
    print(f"New patch written to {PATCH_FILE}")
    # Clean up the repo
    cleanup()


def copy_repo_to_local() -> None:
    """Copy the patched files to the nvim config directories."""
    lua_src = LOCAL_REPO_PATH / "lua" / "claudecode"
    plugin_src = LOCAL_REPO_PATH / "plugin" / "claudecode.lua"
    lua_dest = Path("lua/claudecode")
    plugin_dest = Path("plugin/claudecode.lua")
    # Copy lua/claudecode directory
    if lua_src.exists():
        if lua_dest.exists():
            shutil.rmtree(lua_dest)
        shutil.copytree(lua_src, lua_dest)
        print(f"Copied {lua_src} -> {lua_dest}")
    else:
        print(f"Warning: {lua_src} not found", file=sys.stderr)
    # Copy plugin/claudecode.lua
    if plugin_src.exists():
        plugin_dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(plugin_src, plugin_dest)
        print(f"Copied {plugin_src} -> {plugin_dest}")
    else:
        print(f"Warning: {plugin_src} not found", file=sys.stderr)


def cleanup() -> None:
    """Remove the temporary repo."""
    if LOCAL_REPO_PATH.exists():
        shutil.rmtree(LOCAL_REPO_PATH)
        print(f"Cleaned up {LOCAL_REPO_PATH}")
    # Also remove the parent directory if empty
    if LOCAL_REPO_PATH.parent.exists() and not any(LOCAL_REPO_PATH.parent.iterdir()):
        LOCAL_REPO_PATH.parent.rmdir()
        print(f"Cleaned up {LOCAL_REPO_PATH.parent}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Setup claudecode.nvim with custom patches")
    parser.add_argument(
        "--repatch",
        action="store_true",
        help="Generate a new patch from manually fixed conflicts",
    )
    parser.add_argument(
        "--update",
        action="store_true",
        help="Clone repo, apply patches, and copy to local config",
    )
    args = parser.parse_args()
    if args.repatch:
        generate_repatch()
        return
    if args.update:
        sparse_checkout_repo()
        if not apply_patch():
            # Patch failed, leave repo for manual fixing
            sys.exit(1)
        copy_repo_to_local()
        cleanup()
        print("\nSetup complete!")
        return
    print("mode required", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
