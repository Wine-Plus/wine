#!/usr/bin/env python3
"""Add a runner build to a Bottles-format component repository.

    update-index.py REPO_DIR ARCHIVE URL [--channel stable] [--date UNIX]

REPO_DIR is a checkout of the `repo` branch. Writes
    runners/wine/<name>.yml   manifest (file name, URL, MD5, size)
    index.json                source of truth for the index
    index.yml                 the index Q4Wine (and Bottles) read
<name> is the archive name without .tar.xz; the archive must contain one
top-level folder of the same name with bin/wine inside.
"""
import argparse
import hashlib
import json
import os
import re
import time

NAME_RE = re.compile(r"^[A-Za-z0-9._+-]+$")


def md5sum(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    p = argparse.ArgumentParser()
    p.add_argument("repo_dir")
    p.add_argument("archive")
    p.add_argument("url")
    p.add_argument("--channel", default="stable", choices=["stable", "rc", "unstable"])
    p.add_argument("--date", type=int, default=int(time.time()))
    a = p.parse_args()

    file_name = os.path.basename(a.archive)
    if not file_name.endswith(".tar.xz"):
        raise SystemExit("archive must be a .tar.xz")
    name = file_name[: -len(".tar.xz")]
    if not NAME_RE.match(name):
        raise SystemExit(f"invalid runner name: {name}")

    manifest_dir = os.path.join(a.repo_dir, "runners", "wine")
    os.makedirs(manifest_dir, exist_ok=True)
    with open(os.path.join(manifest_dir, name + ".yml"), "w") as f:
        f.write(
            f"Name: {name}\n"
            f"Provider: wine-plus\n"
            f"Channel: {a.channel}\n"
            f"File:\n"
            f"- file_name: {file_name}\n"
            f"  url: {a.url}\n"
            f"  file_checksum: {md5sum(a.archive)}\n"
            f"  file_size: {os.path.getsize(a.archive)}\n"
            f"Post:\n"
            f"- action: rename\n"
            f"  source: {name}\n"
            f"  dest: {name}\n"
        )

    index_json = os.path.join(a.repo_dir, "index.json")
    index = {}
    if os.path.exists(index_json):
        with open(index_json) as f:
            index = json.load(f)
    index[name] = {"Category": "runners", "Sub-category": "wine",
                   "Channel": a.channel, "Date": str(a.date)}
    with open(index_json, "w") as f:
        json.dump(index, f, indent=2, sort_keys=True)
        f.write("\n")

    with open(os.path.join(a.repo_dir, "index.yml"), "w") as f:
        for key in sorted(index, key=lambda k: int(index[k].get("Date", 0)), reverse=True):
            if not NAME_RE.match(key):
                continue
            f.write(f"{key}:\n")
            for field in ("Category", "Sub-category", "Channel", "Date"):
                if field in index[key]:
                    f.write(f"  {field}: '{index[key][field]}'\n")
    print(f"indexed {name}")


if __name__ == "__main__":
    main()
