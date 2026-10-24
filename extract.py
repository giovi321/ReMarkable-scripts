#!/usr/bin/env python3
"""Extract the attachments of mail files into a directory, keeping their names.

Usage: extract.py OUTPUT_DIR MAILFILE...

Replaces munpack, which turned every space and most punctuation in a filename into
"X". Names are decoded the way mail clients do (RFC 2047 and RFC 2231, so accented
and non-Latin names survive). Only a path separator, a control character or a
leading dot is changed. The extension is lowercased so .PDF and .DOCX are handled
like .pdf and .docx. A name already present gets " (2)", " (3)" and so on.

Each file is written under a temporary name and then renamed, so a watcher sees it
appear complete. Prints the path of every file written.
"""
import email
import os
import re
import sys
from email import policy


def clean(name):
    name = re.sub(r"[\x00-\x1f\x7f/\\]", "_", name).strip().lstrip(".")
    base, ext = os.path.splitext(name)
    return (base or "attachment") + ext.lower()


def unique(directory, name):
    base, ext = os.path.splitext(name)
    path, n = os.path.join(directory, name), 2
    while os.path.exists(path):
        path = os.path.join(directory, f"{base} ({n}){ext}")
        n += 1
    return path


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for mailfile in sys.argv[2:]:
        try:
            with open(mailfile, "rb") as f:
                msg = email.message_from_binary_file(f, policy=policy.default)
        except OSError as e:
            print(f"cannot read {mailfile}: {e}", file=sys.stderr)
            continue
        for part in msg.walk():
            if part.is_multipart():
                continue
            name = part.get_filename()
            if not name:
                continue
            data = part.get_payload(decode=True)
            if data is None:
                continue
            dest = unique(out, clean(name))
            tmp = os.path.join(out, f".extract-{os.getpid()}.tmp")
            with open(tmp, "wb") as f:
                f.write(data)
            os.rename(tmp, dest)
            print(dest)


if __name__ == "__main__":
    main()
