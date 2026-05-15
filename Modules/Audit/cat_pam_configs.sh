#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=high
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=2
# BIRTHA_DEPENDS=bash
# description:
#   Collect PAM configuration for backdoor or authentication-flow review.
#
for file in /etc/pam.conf /etc/pam.d/*; do
    [[ -r "$file" ]] || continue
    echo "### $file"
    sed -n '1,220p' "$file"
done
