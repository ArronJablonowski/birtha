#!/bin/bash
# description:
#	Search for all ssh activity 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# shows all successful and failed login attempts tracked by the audit system
journalctl _AUDIT_TYPE=1112 --since "7 days ago" | grep -v '^[[:space:]]*$'

#
# journalctl _AUDIT_TYPE=1112 --since "7 days ago" -o json | jq
