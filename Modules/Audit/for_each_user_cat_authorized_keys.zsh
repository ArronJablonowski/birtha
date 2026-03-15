#!/bin/bash
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
