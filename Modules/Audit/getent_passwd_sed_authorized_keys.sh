#!/bin/bash
# description:
#	gets usernames from passwd (database) file, then uses the user's name to sed (stream editor) the user's authorized key's file. Which contains the public keypair for ssh authentication. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
getent passwd |
cut -d : -f 6 |
sed 's:$:/.ssh/authorized_keys:' |
xargs -d '\n' grep -s -H -e "$pattern" 
