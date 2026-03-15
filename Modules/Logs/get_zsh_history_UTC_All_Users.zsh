#!/bin/bash
# description:
#   get zsh history and convert the epoch timestamps to UTC for all users.
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: Please run with sudo."
   exit 1
fi

USER_DIRS=("/var/root")
for d in /Users/*; do
    [[ "$d" == "/Users/Shared" ]] && continue
    [[ -d "$d" ]] && USER_DIRS+=("$d")
done

printf "%-12s %-22s %s\n" "USER" "TIME (UTC)" "COMMAND"
echo "--------------------------------------------------------------------------"

for dir in "${USER_DIRS[@]}"; do
    username=$(basename "$dir")
    zsh_history="$dir/.zsh_history"

    if [[ -f "$zsh_history" ]]; then
        # We use 'strings' to clean the file and 'perl' or 'awk' for reliable splitting.
        # This approach handles the ": 1773432392:0;command" format.
        
        strings -n 1 "$zsh_history" | while read -r line; do
            # Extract epoch: looks for string between first ':' and second ':'
            if [[ "$line" =~ ^:[[:space:]]*([0-9]+): ]]; then
                epoch="${BASH_REMATCH[1]}"
                # Extract command: everything after the first ';'
                command="${line#*;}"
                
                # Convert to UTC using macOS 'date -r'
                utc_time=$(date -u -r "$epoch" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
                
                printf "%-12s %-22s %s\n" "$username" "$utc_time" "$command"
            fi
        done # < <(strings "$zsh_history") ## breaks on some MacOS versions. fix: pipe output to while
    fi
done