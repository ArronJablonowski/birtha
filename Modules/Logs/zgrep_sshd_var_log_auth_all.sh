#!/bin/bash
# description:
#	zgrep 'sshd' (ssh server) auth logs 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

zgrep 'sshd' /var/log/auth.log*
