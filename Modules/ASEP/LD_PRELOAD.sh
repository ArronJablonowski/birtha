#!/bin/bash
#
#	Attackers often hardcode LD_PRELOAD into system-wide configuration files so it affects every user and every process
#	If you see a path to a .so file in /tmp, /dev/shm, or a hidden folder (e.g., /lib/.hidden.so), you likely have a user-land rootkit
#
#
#
#

# LD_PRELOAD 
sudo grep -r "LD_PRELOAD" /etc/profile /etc/profile.d/ /etc/bash.bashrc /etc/environment

