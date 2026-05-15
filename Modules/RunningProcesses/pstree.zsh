#!/bin/bash
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
#	List Process Tree on MacOS - requires 'pstree' is installed. 
#       brew install pstree
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#

# If File Exists
if [[ -e /usr/local/bin/pstree ]]; then
    /usr/local/bin/pstree
elif [[ -e /opt/homebrew/bin/pstree ]]; then 
    /opt/homebrew/bin/pstree
elif [[ -e /opt/homebrew/Cellar/pstree/2.40/bin/pstree ]]; then 
    /opt/homebrew/Cellar/pstree/2.40/bin/pstree
elif [[ -e /usr/local/Cellar/pstree/2.40/bin/pstree ]]; then 
    /usr/local/Cellar/pstree/2.40/bin/pstree
fi 
