#!/bin/zsh
# description:
#   Unified Logs: Use the log command to query for specific red flags, such as failed SSH attempts or unauthorized sudo usage.	
#
#   Check if the background malware scanner found anything recently. 
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
log show --predicate 'subsystem == "com.apple.XProtectFramework.PluginAPI"' --last 24h 
