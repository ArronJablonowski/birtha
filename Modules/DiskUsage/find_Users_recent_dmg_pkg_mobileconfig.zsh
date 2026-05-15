#!/bin/zsh
# BIRTHA_TYPE=collect
# BIRTHA_OS=macos
# BIRTHA_CATEGORY=filesystem
# BIRTHA_REQUIRES=standard
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=medium
# BIRTHA_OUTPUT=text
# BIRTHA_CONFIDENCE=medium
# BIRTHA_NOISE_LEVEL=high
# BIRTHA_TRIAGE_PRIORITY=4
# BIRTHA_DEPENDS=zsh
# description:
#   Find recently modified macOS installer/config artifacts in user directories.
#
find /Users -type f \( -iname '*.dmg' -o -iname '*.pkg' -o -iname '*.mobileconfig' \) -mtime -14 -print 2>/dev/null
