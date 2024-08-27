#!/bin/bash
# description:
#	zgrep 'Invalid' from the auth log 
#	will show invalid attempts to login. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha  	
#

zgrep 'Invalid' /var/log/auth.log*
