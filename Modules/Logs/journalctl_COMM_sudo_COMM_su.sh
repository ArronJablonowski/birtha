#!/bin/bash
# description:
#	Search for all sudo and su activity 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#


# Search for all sudo and su activity for the last 7 days
journalctl _COMM=sudo _COMM=su --since "7 days ago" | grep -v '^[[:space:]]*$'

# JSON output 
# journalctl _COMM=sudo _COMM=su --since "7 days ago" -o json | jq 
