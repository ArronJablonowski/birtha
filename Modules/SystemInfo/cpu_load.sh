#!/bin/bash
# description:
#	get contents of /proc/stat and format the output using awk - CPU Load/Usage %
#
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha  	
#
grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'
