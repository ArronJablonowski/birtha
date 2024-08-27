#!/bin/bash
# description:
#	Get the CPU's temp
#
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha  	
#
paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'
