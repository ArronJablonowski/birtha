#!/bin/bash
# description:
#   Attackers want to keep access after a reboot. On macOS, this is almost always achieved through Property List (.plist) files.
#
#   Grep command looks for lol bins in all plist files.
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
grep -E "curl|python|bash|osascript|nc -e|socat" /Library/LaunchAgents/*.plist /Library/LaunchDaemons/*.plist ~/Library/LaunchAgents/*.plist