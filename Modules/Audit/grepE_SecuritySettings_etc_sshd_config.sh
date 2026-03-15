#!/bin/bash
# description:
#	cat the contents of sshd_config file. 
#
#	sshd_config is the configuration file for the OpenSSH Server. 
# 	ssh_config is the configuration file for the OpenSSH client. (ie. missing the 'd' from sshd.)
# 
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#


# Review the SSH daemon configuration
grep -E "PermitRootLogin|PasswordAuthentication|PubkeyAuthentication" /etc/ssh/sshd_config
