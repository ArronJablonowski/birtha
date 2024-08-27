#!/bin/bash
# description:
#	hash the files with MD5 
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
md5sum /root/.ssh/authorized_keys
md5sum /home/*/.ssh/authorized_keys
