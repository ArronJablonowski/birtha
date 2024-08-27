#!/bin/bash
# description:
#	hash the files with MD5 
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
sha256sum /root/.ssh/authorized_keys
sha256sum /home/*/.ssh/authorized_keys
