#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=network
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh
# description:
#	The scutil command-line utility can be used to access system proxy configuration on MacOS. 
#       The --proxy flag can be used to report the current system proxy configuration.
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
scutil --proxy
