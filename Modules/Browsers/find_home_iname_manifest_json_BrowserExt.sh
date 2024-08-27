#!/bin/bash
# description:
#	find all 'manifest.json' files that also contain (grep) the string "Default" in their path. 
#
# 	The command will expose browser extension's encoded folder names. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
find /home -iname 'manifest.json' | grep Default
