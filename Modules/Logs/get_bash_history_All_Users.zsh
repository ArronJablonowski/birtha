#!/bin/bash
# description: 
#   Extracts and attributes .bash_history for all system users.
# about: 
#   This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 

# Root Privilege Check
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run with sudo to access /var/root and other user files."
   exit 1
fi

# Build the list of target directories
# include /var/root and all user folders in /Users
USER_DIRS=("/var/root")
for d in /Users/*; do
    [[ "$d" == "/Users/Shared" ]] && continue
    [[ -d "$d" ]] && USER_DIRS+=("$d")
done

# Output File Header
printf "%-15s %-15s %s\n" "USER" "SOURCE" "COMMAND"
echo "---------------------------------------------------------------------------------------"

# Process each directory
for dir in "${USER_DIRS[@]}"; do
    username=$(basename "$dir")
    bash_history="$dir/.bash_history"

    # Only proceed if the bash_history file exists
    if [[ -f "$bash_history" ]]; then
        
        # use 'strings' to ensure only readable text is output.
        strings -n 1 "$bash_history" | while read -r command; do
            
            # Skip empty lines or lines that are just bash comments/timestamps
            # (In some cases, BASH_COMMAND_IGNORE might leave empty lines)
            [[ -z "$command" ]] && continue
            [[ "$command" =~ ^# ]] && continue

            # Output the formatted line
            printf "%-15s %-15s %s\n" "$username" ".bash_history" "$command"
            
        done #< <(strings -n 1 "$bash_history") ## breaks on some MacOS versions. fix: pipe output to while
        
    fi
done
