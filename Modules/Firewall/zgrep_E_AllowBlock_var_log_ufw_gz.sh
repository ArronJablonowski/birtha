#!/bin/bash
# description:
#	zgrep all ufw.log (firewall log) files for ALLOW or BLOCK events.xxx
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
zgrep -E "ALLOW|BLOCK" /var/log/ufw.log*.gz
