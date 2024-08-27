#!/bin/bash
# description:
#	list open files (-i option selects the listing of files with Internet addresses) and grep those with Established connections. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

lsof -i | grep -i estab
