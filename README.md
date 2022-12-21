# birtha - Bash Incident Response & Threat Hunt Automation
A modular bash framework for automating Live IR & Threat Hunting on Unix systems. 


Pre-Usage Setup: 

* Create a new ssh key pair, with a strong password to protect the private key. 
* Distribute the public key to any hosts birth will ssh to. 
  * It is recommended to install the public key under the remote host's root user, so birth can run remote commands and scripts without permissions issues.  


Usage: 

* Run birtha against a single host. Default config file will be used. 
```
./birtha.sh user@hostname
```

* Run birtha against a single IP, and specify a config file via file path. 
```
./birtha.sh <user@IP> ./Modules/Network_Modules.conf
```        
 
 * Run birtha against a list of hosts (.txt - one host per line), and specify a config file via file path. 
```
./birtha.sh </path/to/hostlist.txt> ./Modules/Network_Modules.conf
```        
 
![alt text](https://github.com/ArronJablonowski/birtha/blob/main/birtha.png?raw=true)
