#!/bin/zsh
# description:
#	 List admin group users
#
#	
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
dscl . -read /Groups/admin GroupMembership
