#!/bin/bash
# description:
#	zgrep all syslog files including *.gz archives (without needing to unzip/untar) for the string 'CRON'
#
#	Cron logs store the time the a cron job was started, the user account used, and the command ran.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
zgrep 'CRON' /var/log/syslog*
