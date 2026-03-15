#!/bin/zsh
# description:
#	Hash the contentes of .ssh/ for all users 
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
md5sum /var/root/.ssh/*
md5sum /Users/*/.ssh/*
