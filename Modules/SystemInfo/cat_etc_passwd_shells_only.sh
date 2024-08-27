#!/bin/bash
# description:
#	cat the content of the passwd (user) files, and only list users who have a shell. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
cat /etc/passwd | grep -v "bin\/nologin" | grep -v "bin\/false" | grep -v "bin\/sync"
