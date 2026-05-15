#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=filesystem
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=high
# BIRTHA_TRIAGE_PRIORITY=4
# BIRTHA_DEPENDS=zsh
# description:
#	Uses the find command to search the /home folder for the following (below) extensions.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
find /Users -iname '*.gz' -o -iname '*.xz' -o -iname '*.7z' -o -iname '*.tar*' -o -iname '*.tgz' -o -iname '*.txz'  -o -iname '*.iso' -o -iname '*.zip' -o -iname '*.rar' -o -iname '*.bzip' -o -iname '*.gzip' -o -iname '*.dmg' -o -iname '*.img' -o -iname '*.bz2'
