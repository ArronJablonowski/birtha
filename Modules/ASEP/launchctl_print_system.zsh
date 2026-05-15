#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=persistence
# BIRTHA_REQUIRES=root
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=medium
# BIRTHA_TRIAGE_PRIORITY=3
# BIRTHA_DEPENDS=zsh,launchctl
# description:
#   Collect launchd system domain state for persistence triage on macOS.
#
launchctl print system
