#!/bin/bash
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