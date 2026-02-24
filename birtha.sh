#!/bin/bash
#
# description:
#       This Script will perform Live IR and Threat Hunting on local or remote hosts using ssh keypair authentication.    
#
# usage:
#       Modules can be chosen in the "./Modules.conf" file. Simply comment '#' out lines you don't want to run. 
#       example: $ ./birtha.sh <root@HostName>
#       example: $ ./birtha.sh <root@IPaddr>
#       ** Host lists should contain one 'User@Hostname' per line.)
#       example: $ ./birtha.sh </path/to/hostlist.txt>   
#       example: $ ./birtha.sh </path/to/hostlist.txt>  [./birthaConfigs/Modules.conf]
#       example: $ ./birtha.sh localhost ./birthaConfigs/Network_Modules.conf
#
# about: 
#	    The Birtha project: https://github.com/ArronJablonowski/birtha 
# 	    Author: Arron Jablonowski  	
#       Last Updated: 2024.8.28 
#

#########################################
############ Script Settings ############

multiHostNumber=2 # Setting to trigger multi hosts per module, all at the same time. 
multiHostMax=100 # Don't exceed this number of hosts at a time 
sshDelaySingleHost=0.5 # Slow things down a bit. ( 0.5 sec ) - Don't DoS yourself with too many ssh connections at once. 
sshDelayMultiHost=0.4 #

###############################################
############ Advanced SSH Settings ############

### Set SSH Options here. Recommended to only add to what is listed below. 
SSH_Options=' -q -oStrictHostKeyChecking=no -oPasswordAuthentication=no ' ## BIRTHA'S ORIGINAL SSH SETTINGS ##
# SSH_Options=' -q -oStrictHostKeyChecking=no -oPasswordAuthentication=no -oPubkeyAcceptedAlgorithms=+ssh-rsa ' ## example: force algo ssh-rsa for older (outdated) OpenWRT/dropbear versions ## 

###############################################
# @ll w@rr@n7y 15 nu11 & v01d # 

# Get the current time and format it into a proper directory name to hold the script's results 
#timestamp=$(date|tr ' ' '_' |tr ':' '.') #replace the spaces in date to "_" &  ':' to '.'  ## Old version 
timestamp=$(date +%Y_%m_%d_%H_%M_%S%z)

# ASCII ART 
echo_ascii1(){
clear 	
echo '' 
echo '                      by: Arron Jablonowski                       '
echo '         BASH INCIDENT RESPONSE & THREAT HUNT AUTOMATION          ' 
echo '      _                      _______                       _      '
echo '   _dMMMb._              .ad0000100000ba               _,dMMMb_   '
echo '  dP  ~YMMb             d001001010000010b            aMMP~  `Yb   '
echo '  V      ~"Mb          d00100000101001000b          dM"~      V   '
echo '           `Mb.       d0010000101010100010b       ,dMl            '
echo '            `YMb._   |000000000000000000000|   _,dMPl             '
echo '       __     `YMMM| OP~~"YOOOOOOOOOOOP"~~YO |MMMPl     __        '
echo '     ,dMMMb.     ~~~ OO     `YOOOOOP`     OO ~~~     ,dMMMb.      '
echo '  _,dP~  `YMba_      OOb      `OOO`      dOO      _aMMP   ~Yb._   '
echo ' <MMP      `~YMMa_   YOOo   @   V  @    oOOP   _adMP~       `YMM> '
echo '              `YMMMM\`OOOo     /O\     oOOO /MMMMP                '
echo '      ,aa.      `~YMMb OOOb._,dOOOb._,dOOO dMMP~        ,aa.      '
echo '    ,dMYYMba._          00101000100010100          _,adMYYMb.     '
echo '   ,MP    `YMMba._      01001000101000100       _,adMMP    `YM.   '
echo '   MP         ~YMMMba._ 00100111111010010  _,adMMMMP~       `YM   '
echo '   YMb           ~YMMMM\`00011^SSH^01010/MMMMP~            dMP    '
echo '    `Mb.           `YMMMb`OO00011100010,dMMMP            ,dM      '
echo '      `                    01000100100                    `       '
echo '         `Mb.         dMMMb` ~OO1OO~ ,dMMMb           `ab         '
echo '        YMb        /MMMMP             `YMMMb            dM        '
echo '       MP       _,adMMP~                 ~YMMba.         YMb      ' 
echo '       YM._   ,adMMP                       `YMMba._    ,MMP       '
echo '         adMYYMb/            ~~~~~~~~         ,dMYYMbYab`         '
echo '           `aa"               BIRTHA              `aa"            '
echo '                             ~~~~~~~~                             '
echo '' 
#sleep 2
} 
echo_ascii1

# Script Functions
echo_config() {
    configlinecount=0
    configFile=$1
    echo ""
    echo "CONFIG FILE FOUND: $configFile"
    sleep 2
    echo "LISTING MODULES:"
    while IFS= read -r line
	do	
        ((configlinecount++))
        #if line is not a comment 
        if grep -q "\#" <<< "$line"; then #if commented "#" then skip 
            continue #basically do nothing... 
        else
            ##Skip config lines with any " " blank spaces 
            if !(test -z "${line// }"); then  # ${line// } >> '// ' removes spaces prior to checking 
                echo " [ Line: $configlinecount ] - Module: $line " # verbose w/line count
                # echo " - Module: $line "                
            fi
        fi 
	done < "$configFile"
    sleep 5
}

check_config(){
    configFile=$1
    #Check if Config file exists  
    if test -z "$configFile"; then 
        echo "!!! ERROR !!! -- Config File Not Found!"
        exit  
    fi
}

### Run ALL modules against ONE host at a time. ### 
Run_LiveIR() {   
    userAtHost=$1
    configFile=$2

    echo_ascii1
    echo_config $configFile # Echo the config 
    echo_ascii1

    while IFS= read -r script_module # read each line of the conif and run "script_module" on host(s).
	do	
        script_fullname=$(echo $script_module | cut -f4 -d'/') # remove path from string
        script_module_dir=$(echo $script_module | cut -f3 -d'/') # remove path from string
        script_name=$(echo $script_fullname | cut -f1 -d'.') # remove .sh from script name 
        #hostname_only=$(echo $userAtHost | cut -f2 -d '@') # get only the host name or IP 

        # if line is not a comment 
        if ! grep -q "\#" <<< "$script_module"; then # if not (!) commented "#" line in birtha config file  
            if !(test -z "${script_module// }"); then   ## Skip config lines with any " " blank spaces 
                if test -f $(echo ${script_module} | sed -e 's/^ *//g;s/ *$//g'); then # Remove leading/trailing spaces and test if config file exists 
                    # make dir(s) if it does not exist
                    [[ -d "./Results" ]] || mkdir "./Results"  # Ensure the './Results' dir exists 
                    [[ -d "./Results/$timestamp" ]] || mkdir "./Results/$timestamp" # Make a dir with the current timestamp 
                    [[ -d "./Results/$timestamp/$script_module_dir" ]] || mkdir "./Results/$timestamp/$script_module_dir"
                    [[ -d "./Results/$timestamp/$script_module_dir/$script_name" ]] || mkdir "./Results/$timestamp/$script_module_dir/$script_name"
                    echo " ~ $ ssh $userAtHost < $script_fullname"
                    ssh $SSH_Options $userAtHost < "$(echo ${script_module} | sed -e 's/^ *//g;s/ *$//g')" > "./Results/$timestamp/$script_module_dir/$script_name/$userAtHost-$script_name.txt" 2>/dev/null &
                    #sleep 0.5 # Slow things down a bit. Don't DoS yourself with too many ssh connections at once. 
                    sleep $sshDelaySingleHost
                else
                    echo " X !3rr0r! -- Script NOT Found: $script_module"
                fi 
            fi            
        fi    
	done < "$configFile"
    wait # wait for each host to complete before proceeding. 
}


### Run ONE modules against ALL host(s) at a time. ### 
Run_LiveIR_Multi_Hosts() {   
    userAtHostList=$1
    configFile=$2

    echo_ascii1
    echo_config $configFile # Echo the config 
    echo_ascii1
    while IFS= read -r script_module
    do	
        # echo_ascii1
        while IFS= read -r usernameAtHost
        do	
            script_fullname=$(echo $script_module | cut -f4 -d'/') # remove path from string
            script_module_dir=$(echo $script_module | cut -f3 -d'/') # remove path from string
            script_name=$(echo $script_fullname | cut -f1 -d'.') # remove .sh from script name 
            #hostname_only=$(echo $userAtHost | cut -f2 -d '@') # get only the host name or IP 

            # if line is not a comment 
            if ! grep -q "\#" <<< "$script_module"; then # if not (!) commented "#" line in birtha config file  
                if !(test -z "${script_module// }"); then   ## Skip config lines with any " " blank spaces 
                    if test -f $(echo ${script_module} | sed -e 's/^ *//g;s/ *$//g'); then # Remove leading/trailing spaces and test if config file exists 
                        # make dir(s) if it does not exist
                        [[ -d "./Results" ]] || mkdir "./Results"  # Ensure the './Results' dir exists 
                        [[ -d "./Results/$timestamp" ]] || mkdir "./Results/$timestamp" # Make a dir with the current timestamp 
                        [[ -d "./Results/$timestamp/$script_module_dir" ]] || mkdir "./Results/$timestamp/$script_module_dir"
                        [[ -d "./Results/$timestamp/$script_module_dir/$script_name" ]] || mkdir "./Results/$timestamp/$script_module_dir/$script_name"
                        echo " ~ $ ssh $usernameAtHost < $script_fullname"
                        ssh $SSH_Options $usernameAtHost < "$(echo ${script_module} | sed -e 's/^ *//g;s/ *$//g')" > "./Results/$timestamp/$script_module_dir/$script_name/$usernameAtHost-$script_name.txt" 2>/dev/null &
                        #sleep 0.1
                        sleep $sshDelayMultiHost
                    else
                        echo " X !3rr0r! -- Script NOT Found: $script_module"
                    fi 
                fi            
            fi   

        done < "$userAtHostList"    
        wait # wait for hosts to complete before proceeding to the next module. 
    
    done < "$configFile"

}

error_message(){
    echo_ascii1
    echo ""
    echo "!!! ERROR !!! -- S0m3 7h1ng w3n7 wr0ng. "
	echo "Please run birtha.sh as follows: "
	echo "$ ./birtha.sh <user@hostname> "
    echo "$ ./birtha.sh <user@hostname> [</path/to/birthaConfig.conf>] "
	echo "$ ./birtha.sh </path/to/hostlist.txt> (*Host list should contain one user@hostname per line.)"
    echo "$ ./birtha.sh </path/to/hostlist.txt> [</path/to/config.conf>]  "
    exit
}

#
#Run_Analysis() { # examp. cat ./Results/Fri_26_Feb_2021_11.03.32_PM_CST/cat_passwd/*
#    #while IFS= read -r line
#        cat "./Results/$timestamp/$script_module/"
#    #done < "$configFile"
#}


# Check if run argument is missing, if it is missing error and exit 
if test -z "$1"; then # $1 is a positional parameter
	# then $1 is null 
	error_message
else 
    reverseit=$(echo $1 | rev) # reverse the order of the string to get the extension first 
    inputs_extension=$(echo $reverseit | cut -d'.' -f1 | rev) # cut on the '.' and reverse the extension back 
    
    if [ "$inputs_extension" == "txt" ]; then 
        echo "      [ HOST FILE: $1 ]"
        sleep 1
    elif [ "$inputs_extension" == "conf" ]; then 
        echo "Position 1 is a config (conf) file"
        error_message
        sleep 1
        exit
    fi

fi 

# IF config file param is null, then run the default config 
if test -z "$2"; then 
    #Config file contains instructions to run scripts on remote hosts. 
    configFile="./BirthaConfigs/Default_Modules.conf"
    check_config $configFile #Check config file exists function 
else 
    configFile=$2 # set config file location to user input 
    check_config $configFile #Check config file exists function 
fi

 
## Script starts running here ##
################################
if test -f "$1"; then  # Check If file (hostlist) exists 
    hostcount=$(cat $1 | wc -l)
    if [ "$hostcount" -ge "$multiHostNumber" ]; then 
        echo "      [ Host Count: $hostcount ]"
        sleep 2
        echo "      [ Mutiple Host mode: ENABLED ] "
        sleep 2
        Run_LiveIR_Multi_Hosts $1 $2
    else 
        while IFS= read -r userAtHost
        do	
            #call Run_LiveIR function for each host in the hostlist ($1)
            Run_LiveIR $userAtHost $2		
        done <"$1"
    fi 
else #Else it must be a userName@hostName/ip     
    #call Run_LiveIR function
    Run_LiveIR $1 $2
fi 

echo " "
echo ">> Results can be Found in the 'Results' Folder: "
echo "------------------------------------------------ "
echo " --> './birtha-main/Results/$timestamp/{ *HERE* }'"
echo " "
