#!/bin/bash
# description:
#	get contents of passwd (database) file, and egrep for UID 0 
#	look for unexpected accounts with a UID of '0' - zero 
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
md5sum /root/.ssh/*
md5sum /home/*/.ssh/*
