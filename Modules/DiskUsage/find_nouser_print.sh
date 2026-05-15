#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=unix
# BIRTHA_CATEGORY=filesystem
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=high
# BIRTHA_TRIAGE_PRIORITY=4
# BIRTHA_DEPENDS=bash
# description:
#	find - search for files in a directory hierarchy
#		(-nouser - No user corresponds to file's numeric user ID) 
#		(-print - print the full file name on the standard output, followed by a newline ) 
# 	
#	Look for orphaned files, which could be a sign of an
# 	attacker's temporary account that has been deleted.
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
#
find / -nouser -print
