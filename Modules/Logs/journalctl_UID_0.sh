#!/bin/bash
# description:
#	Get all activity for UID 0 (root) users
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# Get all activity for UID 0 (root) users, and remove any white spaces 
journalctl _UID=0 --since "7 days ago" | grep -v '^[[:space:]]*$'

# JSON output 
# journalctl _UID=0 --since "7 days ago" -o json | jq