#!/bin/bash
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