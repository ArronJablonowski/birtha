#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=1
# BIRTHA_DEPENDS=bash,find
# description:
#   Collect ownership, permissions, timestamps, hashes, and contents for authorized_keys files.
#
find /root /home -path '*/.ssh/authorized_keys' -type f -print 2>/dev/null |
while IFS= read -r keyfile; do
    echo "### $keyfile"
    ls -la "$keyfile" 2>/dev/null
    if command -v stat >/dev/null 2>&1; then
        stat "$keyfile" 2>/dev/null || true
    fi
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$keyfile" 2>/dev/null || true
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$keyfile" 2>/dev/null || true
    fi
    sed -n '1,120p' "$keyfile" 2>/dev/null
done
