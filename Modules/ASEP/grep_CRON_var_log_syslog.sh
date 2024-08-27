#!/bin/bash
# description:
#	cat syslog's content and grep for string 'CRON' 
#
#	Cron logs store the time the a cron job was started, the user account used, and the command ran. 
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
cat /var/log/syslog | grep CRON
