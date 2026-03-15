#!/bin/zsh
#
# description:
#
#	List names of all apps using Spotlight metadata (more comprehensive for apps stored in various locations): 
#        The mdfind command uses the Spotlight index to locate all items identified as an "Application" 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
mdfind "kMDItemKind == 'Application'"
