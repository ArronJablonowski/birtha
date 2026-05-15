#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=system
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh
# description:
#	list the /mnt directroy 
#		(-l use a long listing format)
#		(-a do not ignore entries starting with '.' )
#		(-t sort by modification time, newest first )
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
ls -lat /Volumes
