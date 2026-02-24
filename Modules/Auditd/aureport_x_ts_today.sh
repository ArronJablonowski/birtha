#!/bin/bash
# description:
#	 a sequential list of every process execution today
#        * requires auditd to be installed 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# a sequential list of every process execution today
aureport -x -ts today 
