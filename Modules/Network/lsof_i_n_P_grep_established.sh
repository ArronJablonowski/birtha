#!/bin/bash
# description:
#	list open files 
#		(-i option selects the listing of files with Internet addresses) 
#		(-n show numbers/IPs only, and don't resolve IPs to host names) 
#		(-P show the PID/processes ID for the listing ) 
# 
#	grep for ESTABLISHED connections
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
lsof -i -n -P | grep -i estab
