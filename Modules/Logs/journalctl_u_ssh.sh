#!/bin/bash
# description:
#	Search for all ssh activity 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# search for all ssh activity for the last 7 days and remove white spaces from results 
journalctl -u ssh --since "7 days ago" | grep -v '^[[:space:]]*$'

# JSON output 
# journalctl -u ssh --since "7 days ago" -o json | jq