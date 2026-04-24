# birtha - Bash Incident Response & Threat Hunting Automation

*"birtha: Because you can't install EDR on everything, and EDR can't give you every log."*

## Introduction

**birtha** is an advanced modular bash framework designed to automate incident response (IR) and threat hunting tasks on Unix-based systems. This tool empowers security teams 
with the ability to efficiently assess, analyze, and respond to potential threats across multiple hosts.

## Pre-Usage Setup

Before using birtha, ensure you have a strong understanding of its capabilities and requirements:

1. **Generate SSH Key Pair**:
   - Create a new SSH key pair with a strong passphrase for protection.
     ```bash
     ssh-keygen -t ed25519 -f ./path/to/private/key/IncidentResponse_ed25519 -N "your_strong_passphrase"
     ```

2. **Distribute Public Key**:
   - Add the public key to any hosts that birtha will connect to.
   - It is recommended to distribute the public key under the root user for seamless execution of remote commands and scripts.

## Usage
### Add you private key to the ssh agent before running birtha
```bash
ssh-add ./path/to/private/key/IncidentResponse_ed25519
```
### Running against a Single Host

To run birtha against a single host using the default configuration file:

```bash
./birtha.sh <adminUsername@hostname>
```

### Specifying a Configuration File

To specify a custom configuration file when running against a single host:

```bash
./birtha.sh <adminUsername@hostname> ./BirthaConfigs/Default_Modules.conf
```

### Running against a List of Hosts

To run birtha against a list of hosts (one per line in the text file) and specify a custom configuration file:

```bash
./birtha.sh ./HostLists/hosts.txt ./BirthaConfigs/Default_Modules.conf
```

## Configuration Files

The default configuration file `Default_Modules.conf` includes a variety of modules for different tasks, such as listing network connections, process enumeration, log analysis, and more. 
You can customize this file or create your own by editing the sections under "####### >>> Network <<< #######" and so on.

Each module is represented by a command or a script that will be executed on the remote host. By default, birtha will run all modules against a single host at a time. For multiple hosts, you can specify how many hosts to process simultaneously using the `multiHostNumber` and `sshDelaySingleHost` variables in the script.

## Example Configuration File

Here's an example of a custom configuration file that includes specific modules for listing network connections and log analysis:

```bash
# Default_Modules.conf

####### >>> Network <<< #######
./Modules/Network/lsof_i_n_P.sh
./Modules/Network/netstat_tuapnv.sh

####### >>> Logs <<< #######
./Modules/Logs/zgrep_sshd_var_log_auth_all.sh
./Modules/Logs/zgrep_useradd_var_log_auth_all.sh
```

## Output and Results

After running birtha, the results will be stored in a timestamped directory within the `Results` folder. Each module's output will be saved in its respective subdirectory for easy review.

## Troubleshooting

If you encounter any issues during the execution of birtha, consider the following troubleshooting steps:

1. **Check SSH Key Permissions**:
   - Ensure that your private key has the correct permissions (e.g., `chmod 600 ./path/to/private/key/IncidentResponse_ed25519`).

2. **Verify Remote Host Accessibility**:
   - Double-check that you can SSH into each host using the specified username and IP address.

3. **Check for Module Errors**:
   - Review the output files in the `Results` directory to identify any errors or issues encountered during module execution.

## Conclusion

birtha is a powerful tool for automating incident response tasks on Unix-based systems. By following the pre-usage setup instructions, and using the provided configuration file examples, you can efficiently respond to threats across multiple hosts with ease.

        
 
![alt text](https://github.com/ArronJablonowski/birtha/blob/main/img/birtha.png?raw=true)
