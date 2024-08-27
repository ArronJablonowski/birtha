#!/bin/bash
# description:
#	RPM Package Manager
#		(-a - all, Query all installed packages ) 
#		(-V - verify packages ) 
#
#	Linux machine with RPM installed (RedHat,
# 	Mandrake, etc.), run the RPM tool to verify packages:
# 		rpm –Va
#
# 	This checks size, MD5 sum, permissions, type,
#	owner, and group of each file with information from
#	RPM database to look for changes. Output includes:
#		S – File size differs
#		M – Mode differs (permissions)
#		5 – MD5 sum differs
#		D – Device number mismatch
#		L – readLink path mismatch
#		U – user ownership differs
#		G – group ownership differs
#		T – modification time differs
#	Pay special attention to changes associated with
#	items in /sbin, /bin, /usr/sbin, and /usr/bin.
#	In some versions of Linux, this analysis is automated
#	by the built-in check-packages script.
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
#
rpm -Va | sort
