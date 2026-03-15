#!/bin/zsh 
#
#
#

#!/bin/bash
# Enhanced Extension Audit for all Users

OUTPUT="extension_audit_all_users.txt"
echo "--- Multi-User Extension Audit ($(date)) ---" > $OUTPUT

# Define target directories for common browsers
# We skip system accounts by checking if a directory exists in /Users
for user_dir in /Users/*; do
    username=$(basename "$user_dir")
    
    # Skip directories that aren't actual user homes
    if [ "$username" == "Shared" ]; then continue; fi

    echo -e "\n[+] Auditing extensions for user: $username" >> $OUTPUT
    
    # Chrome Extensions (per user)
    CHROME_PATH="$user_dir/Library/Application Support/Google/Chrome/Default/Extensions/"
    if [ -d "$CHROME_PATH" ]; then
        echo "Found Chrome Extensions in $username:" >> $OUTPUT
        # List extension IDs and creation dates
        ls -lt "$CHROME_PATH" >> $OUTPUT 2>/dev/null
    fi

    # Safari Extensions (per user)
    SAFARI_PATH="$user_dir/Library/Safari/Extensions/"
    if [ -d "$SAFARI_PATH" ]; then
        echo "Found Safari Extensions in $username:" >> $OUTPUT
        ls -lt "$SAFARI_PATH" >> $OUTPUT 2>/dev/null
    fi
done

echo "Audit complete. Results saved to $OUTPUT"
