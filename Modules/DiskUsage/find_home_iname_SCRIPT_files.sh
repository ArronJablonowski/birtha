#!/bin/bash
# description:
#	Uses the find command to search the /home folder for the following (below) extensions.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
find /home -iname '*.deb' -o -iname '*.dpkg' -o -iname '*.sh' -o -iname '*.py' -o -iname '*.pl' -o -iname '*.c' -o -iname '*.h' -o -iname '*.php' -o -iname '*.rpm' -o -iname '*.bin' -o -iname '*.elf' -o -iname '*.so' -o -iname '*.o'
