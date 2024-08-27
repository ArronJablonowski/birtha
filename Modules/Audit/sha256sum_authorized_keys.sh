#!/bin/bash
# description:
#	hash the authorized_Keys files with sha256 
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
sha256sum /root/.ssh/authorized_keys
sha256sum /home/*/.ssh/authorized_keys
