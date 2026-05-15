#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=logs
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=high
# BIRTHA_TRIAGE_PRIORITY=4
# BIRTHA_DEPENDS=zsh,log
# description:
#   Unified Logs: Use the log command to query for specific red flags, such as failed SSH attempts or unauthorized sudo usage.	
#
#   Check if the background malware scanner found anything recently. 
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
log show --predicate 'subsystem == "com.apple.XProtectFramework.PluginAPI"' --last 24h 
