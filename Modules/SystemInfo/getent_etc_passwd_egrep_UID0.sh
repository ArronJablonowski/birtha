#!/bin/bash
# description:
#	get contents of passwd (database) file, and egrep for UID 0 
#	look for unexpected accounts with a UID of '0' - zero 
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
getent passwd | egrep ':0+:'
