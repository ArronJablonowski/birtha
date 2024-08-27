#!/bin/bash
# description:
#	zgrep (-v) ommiting 'package-system-locked' and grep for 'COMMAND', then format output.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

zgrep -v package-system-locked /var/log/auth.log*.gz | grep COMMAND | cut -d':' -f 4,5,6 | cut -c 4-
