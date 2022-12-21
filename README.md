# birtha - Bash Incident Response & Threat Hunt Automation
A modular bash framework for automating Live IR & Threat Hunting on Unix systems. 


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
