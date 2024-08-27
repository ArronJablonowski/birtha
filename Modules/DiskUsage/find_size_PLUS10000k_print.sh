#!/bin/bash
# description:
#	Uses the find command to search / for files larger than 10,000k 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
find / -size +10000k -print
