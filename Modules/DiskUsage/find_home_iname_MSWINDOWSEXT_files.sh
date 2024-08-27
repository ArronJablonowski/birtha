#!/bin/bash
# description:
#	Uses the find command to search the /home folder for the following (below) extensions.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha  	
#
find /home -iname '*.exe' -o -iname '*.dll' -o -iname '*.bat' -o -iname '*.cmd' -o -iname '*.msi'
