#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=process
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh
# description:
#	report a snapshot of the current processes
#		(-a Select all processes except both session leaders (see getsid) and processes not associated with a terminal)
#		(-x this option causes ps to list all processes owned by you (same EUID as ps), or to list ALL processes when used together with the a option)
#		(-ww Wide Wide - tells macOS to ignore the window width entirely and show the full command string, no matter how long it is)
#		(-o User Defined Output - allows for defined columns in the output)  
#
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
ps -axwwo user,pid,ppid,pgid,command
