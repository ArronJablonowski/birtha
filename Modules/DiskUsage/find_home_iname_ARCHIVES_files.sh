#!/bin/bash
# description:
#	Uses the find command to search the /home folder for the following (below) extensions.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
find /home -iname '*.gz' -o -iname '*.xz' -o -iname '*.7z' -o -iname '*.tar*' -o -iname '*.tgz' -o -iname '*.txz'  -o -iname '*.iso' -o -iname '*.zip' -o -iname '*.rar' -o -iname '*.bzip' -o -iname '*.gzip' -o -iname '*.dmg' -o -iname '*.img' -o -iname '*.bz2'
