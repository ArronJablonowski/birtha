#!/bin/bash
# description:
#	grep 'Invalid' from auth log. 
# 	will show invalid attempts to login
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

grep 'Invalid' /var/log/auth.log
