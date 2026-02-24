#!/bin/bash
# description:
#	Init/Systemd scripts and user-level autostart files	
#
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# Systemd timers
systemctl list-units --type=service --state=running