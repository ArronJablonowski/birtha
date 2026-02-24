#!/bin/bash
# description:
#	 a ranked list of every program that has been launched
#        * requires auditd to be installed 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# a ranked list of every program that has been launched
aureport -x --summary
