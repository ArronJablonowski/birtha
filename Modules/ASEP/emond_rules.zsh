#!/bin/zsh
#
#

# List all emond rule files
ls -la /etc/emond.d/rules/

# Examine the content of any suspicious rule
plutil -p /etc/emond.d/rules/*.plist
