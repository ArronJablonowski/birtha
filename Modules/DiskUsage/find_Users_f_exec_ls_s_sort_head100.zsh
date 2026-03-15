#!/bin/zsh
# description:
#	Uses the find command to search the /Users folder for the x number of largest files. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
find /Users -type f -exec ls -s {} + | sort -nr | head -n 100 | awk '{
    s=$1/2; # Convert 512-byte blocks to KB
    if (s>=1048576) printf "%.2f GB", s/1048576;
    else if (s>=1024) printf "%.2f MB", s/1024;
    else printf "%.2f KB", s;
    $1=""; print $0
}'

