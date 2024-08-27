#!/bin/bash
# description:
#
#	cat the contents of fstab
#
# 	/etc/fstab contains the necessary information to automate the process of mounting partitions. In a nutshell, mounting is the process where a raw (physical) partition is prepared for access and assigned a location on the file system tree (or mount point).
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
cat /etc/fstab
