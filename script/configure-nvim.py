import os
import sys
import shutil
import subprocess

WINDOWS = sys.platform == "win32"

if WINDOWS:
    NVIM_HOME = os.path.join(os.path.expanduser("~"), "AppData", "Local", "nvim")
else:
    NVIM_HOME = os.path.join(os.path.expanduser("~"), ".config/nvim")

DOTBIN_CONFIG = os.path.join(os.path.dirname(os.path.dirname(__file__)), "dotconfig")

def copy_config_file(src, dst, ignore_keep=False):
    """
        Copy src to dst

        If ignore_keep, don't respect @keep-start or @keep-end
        Keep logic only applies to .lua files
    """
    dir_path = os.path.dirname(dst)
    if not os.path.exists(dir_path):
        os.makedirs(dir_path, exist_ok=True)

    # For non-.lua files, just copy directly
    if not src.endswith(".lua"):
        shutil.copy(src, dst)
        return

    keep_sections = []
    if not os.path.exists(dst):
        ignore_keep = True
    else:
        # process keep sections
        with open(dst, "r", encoding="utf-8") as f:
            current_keep_section = []
            in_keep_scope = False
            for line in f:
                if not in_keep_scope:
                    if line.startswith("-- @keep-start"):
                        in_keep_scope = True
                        current_keep_section = []
                else:
                    if line.startswith("-- @keep-end"):
                        in_keep_scope = False
                        keep_sections.append(current_keep_section)
                    else:
                        current_keep_section.append(line.rstrip())
            if in_keep_scope:
                raise ValueError("Keep section not closed")

    lines = []
    if ignore_keep:
        with open(src, "r", encoding="utf-8") as f:
            for line in f:
                lines.append(line.rstrip())

    else:
        with open(src, "r", encoding="utf-8") as f:
            current_keep_section_i = -1
            in_keep_scope = False
            for line in f:
                if not in_keep_scope:
                    lines.append(line.rstrip())
                    if line.startswith("-- @keep-start"):
                        current_keep_section_i += 1
                        # only process section if it exists in dst
                        # otherwise use the one from src
                        if current_keep_section_i < len(keep_sections):
                            in_keep_scope = True
                            lines.extend(keep_sections[current_keep_section_i])
                else:
                    if line.startswith("-- @keep-end"):
                        in_keep_scope = False
                        lines.append(line.rstrip())

            if in_keep_scope:
                raise ValueError("Keep section not closed")

    content = "\n".join(lines)
    while content.endswith("\n") or content.endswith("\r"):
        content = content[:-1]
    content += "\n"

    with open(dst, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)


def copy_config_dir(src, dst, path, ignore_keep=False):
    src_path = os.path.join(src, path)
    for entry in os.listdir(src_path):
        sub_path = os.path.join(path, entry)
        src_path = os.path.join(src, sub_path)
        if os.path.isdir(src_path):
            copy_config_dir(src, dst, sub_path, ignore_keep)
        else:
            dst_path = os.path.join(dst, sub_path)
            print(f"cp {src_path} {dst_path}")
            copy_config_file(src_path, dst_path, ignore_keep=ignore_keep)

def comment_out_file(file):
    with open(file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    # is it already commented out?
    if all(line.startswith("--") for line in lines):
        return

    with open(file, "w", encoding="utf-8") as f:
        for line in lines:
            f.write("-- " + line)

def comment_out_extra_files(src, dst, path):
    dst_path = os.path.join(dst, path)
    if not os.path.exists(dst_path):
        return
    for entry in os.listdir(dst_path):
        sub_path = os.path.join(path, entry)
        src_path = os.path.join(src, sub_path)
        dst_path = os.path.join(dst, sub_path)
        if os.path.isdir(dst_path):
            comment_out_extra_files(src, dst, sub_path)
        elif not os.path.exists(src_path):
            print(f"commenting out {dst_path}")
            comment_out_file(dst_path)

FILES = [
    "init.lua",
    "claudecode-setup.py",
    "claudecode.patch"
]
DIRS = [
    "lua",
    "after"
]

def copy_to_dotbin(dotbin_nvim):
    print("updating dotconfig/nvim using user config")
    if os.path.exists(dotbin_nvim):
        shutil.rmtree(dotbin_nvim)
    for f in FILES:
        copy_config_file(os.path.join(NVIM_HOME, f), os.path.join(dotbin_nvim, f), ignore_keep=True)
    for d in DIRS:
        copy_config_dir(NVIM_HOME, dotbin_nvim, d, ignore_keep=True)

def copy_to_user(dotbin_nvim):
    print("updating user config with dotconfig/nvim")
    for f in FILES:
        copy_config_file(os.path.join(dotbin_nvim, f), os.path.join(NVIM_HOME, f), ignore_keep=False)
    for d in DIRS:
        comment_out_extra_files(dotbin_nvim, NVIM_HOME, d)
        copy_config_dir(dotbin_nvim, NVIM_HOME, d, ignore_keep=False)

    # Create undotree directory, otherwise things will fail
    home = os.environ.get("HOME") or os.environ.get("USERPROFILE")
    if home:
        undotree_dir = os.path.join(home, ".vim", "undotree")
        if not os.path.exists(undotree_dir):
            print(f"mkdir -p {undotree_dir}")
            os.makedirs(undotree_dir, exist_ok=True)

    # Run claudecode-setup.py
    setup_script = os.path.join(NVIM_HOME, "claudecode-setup.py")
    if os.path.exists(setup_script):
        print(f"running {setup_script}")
        subprocess.run([sys.executable, setup_script, "--update"], cwd=NVIM_HOME, check=True)

if __name__ == "__main__":
    dotbin_nvim = os.path.join(DOTBIN_CONFIG, "nvim")
    if len(sys.argv) > 1 and sys.argv[1] == "--reverse":
        copy_to_dotbin(dotbin_nvim)
    else:
        copy_to_user(dotbin_nvim)
