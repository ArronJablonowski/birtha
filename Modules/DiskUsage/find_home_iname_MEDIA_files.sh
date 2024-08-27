#!/bin/bash
# description:
#	Uses the find command to search the /home folder for the following (below) extensions.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
find /home -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.mov' -o -iname '*.avi' -o -iname '*.mp3' -o -iname '*.mp4' -o -iname '*.iso'
