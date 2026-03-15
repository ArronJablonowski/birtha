#!/bin/zsh
# description:
#   Unified Logs: Use the log command to query for specific red flags, such as failed SSH attempts or unauthorized sudo usage.	
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
log show --predicate 'eventMessage contains "sudo"' --last 8h 
