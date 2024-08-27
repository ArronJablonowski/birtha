#!/bin/bash
# description:
#	Hash the contentes of .ssh/ for all users 
#	
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 	
#
md5sum /root/.ssh/*
md5sum /home/*/.ssh/*
