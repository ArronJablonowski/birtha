#!/bin/bash
# description:
#	sort lines of passwd file by UID
#	Normal accounts will be there, but look for new, unexpected accounts, especially with UID < 500.
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
sort -nk3 -t: /etc/passwd
