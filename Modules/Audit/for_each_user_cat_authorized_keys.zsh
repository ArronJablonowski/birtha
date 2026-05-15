#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=audit
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh
# description:
#	 cat authorized_keys for each user
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#


# Check the root user and regular user directories
for user_dir in /Users/* /var/root; do
    if [ -f "$user_dir/.ssh/authorized_keys" ]; then
        echo "--- Keys found in $user_dir/.ssh/authorized_keys ---"
        cat "$user_dir/.ssh/authorized_keys"
    fi
done 
