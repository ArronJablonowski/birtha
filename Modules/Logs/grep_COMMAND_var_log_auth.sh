#!/bin/bash
# description:
#	grep (-v) removing 'package-system-locked', then grep for 'COMMAND' and format output.  
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
grep -v package-system-locked /var/log/auth.log | grep COMMAND | cut -d':' -f 4,5,6 | cut -c 4-
