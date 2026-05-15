#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=2
# BIRTHA_DEPENDS=bash,find
# description:
#   Collect metadata and suspicious lines from shell startup files.
#
find /root /home /etc -maxdepth 3 -type f \( -name '.bashrc' -o -name '.bash_profile' -o -name '.profile' -o -name '.zshrc' -o -name 'profile' -o -name 'bash.bashrc' -o -name 'environment' \) -print 2>/dev/null |
while IFS= read -r file; do
    echo "### $file"
    ls -la "$file" 2>/dev/null
    egrep -n 'curl|wget|base64|bash -c|python|perl|ruby|nc |ncat|socat|LD_PRELOAD|/tmp|/dev/shm|chmod \+x' "$file" 2>/dev/null || true
done
