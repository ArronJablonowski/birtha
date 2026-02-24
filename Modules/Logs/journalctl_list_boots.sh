#!/bin/bash
# description:
#	List boot times of OS 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# List boot times of OS for the last 7 days and strip white spaces from output 
journalctl --list-boots --since "7 days ago" | grep -v '^[[:space:]]*$'^C

# JSON output 
# journalctl --list-boots --since "7 days ago" -o json | jq