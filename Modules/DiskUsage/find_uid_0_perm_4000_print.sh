#!/bin/bash
# description:
#	find unusual SUID root files
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
find / -uid 0 -perm -4000 -print
