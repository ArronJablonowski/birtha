#!/bin/bash
# description:
#	Zgrep all auth logs for a user being added to the system. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

zgrep -i -E "*useradd*|*adduser*" /var/log/auth.*
