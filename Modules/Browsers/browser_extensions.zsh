#!/bin/zsh 
#
#
#

#!/bin/bash
# Enhanced Extension Audit for all Users

#!/bin/bash
# Enhanced Extension Audit for all Users - CLI Output Version

#!/bin/bash
# Enhanced Extension Audit for all Users - CLI Output Version (Chrome, Safari, Firefox)

echo "--- Multi-User Extension Audit ($(date)) ---"

for user_dir in /Users/*; do
    username=$(basename "$user_dir")
    # Skip Shared directory or non-directories
    if [[ "$username" == "Shared" ]] || [[ ! -d "$user_dir" ]]; then 
        continue 
    fi

    echo -e "\n\033[1;32m[+]\033[0m Auditing extensions for user: $username"
    
    # --- Chrome Extensions ---
    CHROME_PATH="$user_dir/Library/Application Support/Google/Chrome/Default/Extensions/"
    if [ -d "$CHROME_PATH" ]; then
        echo "Found Chrome Extensions for $username:"
        ls -lt "$CHROME_PATH" 2>/dev/null
    fi

    # --- Safari Extensions ---
    SAFARI_PATH="$user_dir/Library/Safari/Extensions/"
    if [ -d "$SAFARI_PATH" ]; then
        echo "Found Safari Extensions for $username:"
        ls -lt "$SAFARI_PATH" 2>/dev/null
    fi

    # --- Firefox Extensions ---
    # Firefox uses random profile names, so we look into Profiles/*
    FIREFOX_BASE="$user_dir/Library/Application Support/Firefox/Profiles"
    if [ -d "$FIREFOX_BASE" ]; then
        # Loop through any profile folders found
        for profile in "$FIREFOX_BASE"/*; do
            EXT_PATH="$profile/extensions"
            if [ -d "$EXT_PATH" ]; then
                # Get the profile name from the path for clarity
                profile_name=$(basename "$profile")
                echo "Found Firefox Extensions for $username (Profile: $profile_name):"
                ls -lt "$EXT_PATH" 2>/dev/null
            fi
        done
    fi
done

echo -e "\n--- Audit complete ---"
