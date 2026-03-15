#!/bin/zsh
#
#

# List user crontab
crontab -l

# Check root's crontab (requires sudo)
sudo crontab -l

# Inspect system-wide cron folders
ls -la /var/at/tabs/
