#!/bin/bash
# description:
#	Uses the find command to search the /home folder for the following (below) extensions.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
find /home -iname 'id_rsa' -o -iname '*.pub' -o -iname '*ecdsa*'
