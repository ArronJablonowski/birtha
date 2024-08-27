#!/bin/bash
# description:
#	find - search for files in a directory hierarchy
#		(-nouser - No user corresponds to file's numeric user ID) 
#		(-print - print the full file name on the standard output, followed by a newline ) 
# 	
#	Look for orphaned files, which could be a sign of an
# 	attacker's temporary account that has been deleted.
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
#
find / -nouser -print
