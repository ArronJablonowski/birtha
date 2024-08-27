#!/bin/bash
# description:
#	Find files that are hidden from (normal) view. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
find / -name " " -o -name "  " -o -name "..." -o -name "... " -o -name ".. " -o -name ". "
