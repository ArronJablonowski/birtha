#!/bin/bash
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=unknown
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh
# description:
#   Attackers want to keep access after a reboot. On macOS, this is almost always achieved through Property List (.plist) files.
#
#   Launch Daemons & Agents: These are the most common persistence points.
#
#        /Library/LaunchDaemons (System-wide, runs as root)
#       /Library/LaunchAgents (Runs when any user logs in)
#       ~/Library/LaunchAgents (Runs when a specific user logs in)
#
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
ls -la /Users/*/Library/LaunchAgents/
