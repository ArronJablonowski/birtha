#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=logs
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=bash
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
