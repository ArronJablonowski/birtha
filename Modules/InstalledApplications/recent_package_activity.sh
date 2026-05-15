#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=software
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=2
# BIRTHA_DEPENDS=bash
# description:
#   Collect recent package manager activity from common Debian, RPM, and yum/dnf logs.
#
for file in /var/log/apt/history.log /var/log/apt/history.log.* /var/log/dpkg.log /var/log/dpkg.log.* /var/log/yum.log /var/log/dnf.log /var/log/rpm.log; do
    [[ -r "$file" ]] || continue
    echo "### $file"
    case "$file" in
        *.gz) zgrep -Ei 'install|upgrade|remove|erase|commandline' "$file" 2>/dev/null | tail -200 ;;
        *) grep -Ei 'install|upgrade|remove|erase|commandline' "$file" 2>/dev/null | tail -200 ;;
    esac
done
