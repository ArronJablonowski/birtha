#!/bin/bash
# description:
#   Harden Ubuntu ssh server by disabling password authentication. 
#   *Test keypair auth prior to disabaling.
#   
# about: 
#	This script is part of the Birtha project: https://github.com/ArronJablonowski/birtha 
#

# set PasswordAuthentication no
sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config 

# set PubkeyAuthentication yes
sudo sed -i -E 's/#?PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config 

# restart service 
service sshd restart 
