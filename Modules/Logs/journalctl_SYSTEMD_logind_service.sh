#!/bin/bash
# description:
#	Track all session openings/closings
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# Track all session openings/closings for the last 7 days and strip white spaces from results 
journalctl _SYSTEMD_UNIT=systemd-logind.service --since "7 days ago" | grep -v '^[[:space:]]*$'

# JSON output 
# journalctl _SYSTEMD_UNIT=systemd-logind.service --since "7 days ago" -o json | jq