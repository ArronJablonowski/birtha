#!/bin/bash
# description:
#	Uses the find command to search the /home folder for files containing the following (below) names.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
find /home -iname '*password*' -o -iname '*user*' -o -iname '*creds*' -o -iname '*credential*' -o -iname '*access*' -o -iname '*login*' -o -iname '*secret*' -o -iname '*protected*'
