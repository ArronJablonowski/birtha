#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=filesystem
# BIRTHA_REQUIRES=standard
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh
# description:
#   List recent user files with Gatekeeper quarantine metadata.
#
find /Users -type f -mtime -14 -print0 2>/dev/null | while IFS= read -r -d '' file; do
    quarantine=$(xattr -p com.apple.quarantine "$file" 2>/dev/null)
    if [[ -n "$quarantine" ]]; then
        printf '%s\t%s\n' "$file" "$quarantine"
    fi
done
