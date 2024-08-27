#!/bin/bash
# description:
#	get the contenst of the passwd (database) file and cut the username. Then get each user's zsh history file.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

getent passwd |
cut -d : -f 6 |
sed 's:$:/.zsh_history:' |
xargs -d '\n' grep -s -H -e "$pattern" 
