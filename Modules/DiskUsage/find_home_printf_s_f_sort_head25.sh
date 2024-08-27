#!/bin/bash
# description:
#	Uses the find command to search the /home folder for the x number of largest files. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
find /home -printf '%s %f\n'| sort -nr | head -25

