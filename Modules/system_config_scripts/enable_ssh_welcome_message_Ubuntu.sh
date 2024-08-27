#!/bin/bash
# description:
#	Change file mode bits, and remove execution. 
#	This will disable the banner/welcome messages when connecting over ssh. 
#	ie. it will keep extra junk out of the log files. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
#
ls -la /etc/update-motd.d/
echo ''
chmod +x /etc/update-motd.d/*
echo ''
echo 'chmod +x /etc/update-motd.d/*'
echo '' 
ls -la /etc/update-motd.d/
