# birtha - Bash Incident Response & Threat Hunt Automation
A modular bash framework for automating Live IR & Threat Hunting on Unix systems. 


Pre-Usage Setup: 

* Create a new ssh key pair, with a strong passphrase to protect the private key.
* Distribute the public key to any hosts birth will ssh to. 
  * It is recommended to add the public key under the remote host's root user so birth can run remote commands and scripts without permissions issues.  


Usage: 

1. Ssh-add (or risk getting tons of prompts for your private key's passphrase)
```
ssh-add ./path/to/private/key/IncidentResponse_ed25519
```

2. (a) Run birtha against a single host. Default config file will be used. 
```
./birtha.sh <adminUsername@hostname>
```

2. (b) Run birtha against a single IP, and specify a config file via file path. 
```
./birtha.sh <adminUsername@hostname> ./BirthaConfigs/Default_Modules.conf
```        
 
2. (c) Run birtha against a list of hosts (.txt - one host per line), and specify a config file via file path. 
```
./birtha.sh ./HostLists/hosts.txt ./BirthaConfigs/Default_Modules.conf
```        
 
![alt text](https://github.com/ArronJablonowski/birtha/blob/main/img/birtha.png?raw=true)
