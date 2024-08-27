#!/bin/bash
# description:
#	grep sshd (ssh server) log events from auth log file
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#

grep 'sshd' /var/log/auth.log
