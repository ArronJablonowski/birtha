#!/bin/bash
# description:
#	list inittab, init.d, init.conf, & init directories 
#
#	>> Init is a daemon that is the first process of a Linux system. It creates processes from scripts stored in the file /etc/inittab. Init is responsible for rebooting, starting, and shutting down the computer
#
#	>> inittab file is the configuration file used by the System V (SysV) initialization system in Linux. This file defines three items for the init process:
#	--the default runlevel
#	-- what processes to start, monitor, and restart if they terminate
#	-- what actions to take when the system enters a new runlevel
#
#	>> Init.d is a directory in the Linux file system that contains scripts for controlling services. These scripts are used to start, stop, reload, and restart services while the system is running or during boot. 
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#
echo "#> Inittab"
echo "----------"
ls -la /etc/inittab

echo ""
echo "#> Init.d"
echo "---------"
ls -la /etc/init.d

echo ""
echo "#> Init.conf"
echo "------------"
ls -la /etc/init.conf

echo ""
echo "#> Init"
echo "-------"
ls -la /etc/init
