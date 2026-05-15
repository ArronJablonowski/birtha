#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=user
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=low
# BIRTHA_TRIAGE_PRIORITY=2
# BIRTHA_DEPENDS=zsh,osascript
# description:
#   Collect legacy Login Items visible through System Events.
#
osascript -e 'tell application "System Events" to get the properties of every login item' 2>&1
