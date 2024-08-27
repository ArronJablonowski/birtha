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
#       Last Updated: 2023.9.18 
#

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
sleep 2
} 
echo_ascii1

# Script Functions
echo_config() {
    echo ""
    echo "CONFIG FILE FOUND: $configFile"
    sleep 1
    echo "LISTING MODULES:"
    while IFS= read -r line
	do	
        #if line is not a comment 
        if grep -q "\#" <<< "$line"; then #if commented "#" then skip 
            continue #basically do nothing... 
        else
            ##Skip config lines with any " " blank spaces 
            if !(test -z "${line// }"); then  # ${line// } >> '// ' removes spaces prior to checking 
                echo " - Module: $line"                
            fi
        fi 
	done < "$configFile"
    sleep 2
}

check_config(){
    #Check if Config file exists  
    if test -z "$configFile"; then 
        echo "!!! ERROR !!! -- Config File Not Found!"
        exit  
    fi
}

### MAIN SSH Function ### 
### This function does all the heavy lifting by running the scripts on remote hosts and reporting the results  
Run_LiveIR() {   
    while IFS= read -r script_module
	do	
        script_fullname=$(echo $script_module | cut -f4 -d'/') # remove path from string
        script_module_dir=$(echo $script_module | cut -f3 -d'/') # remove path from string
        script_name=$(echo $script_fullname | cut -f1 -d'.') # remove .sh from script name 
        # if line is not a comment 
        if ! grep -q "\#" <<< "$script_module"; then # if not (!) commented "#" line in birtha config file  
            if !(test -z "${script_module// }"); then   ## Skip config lines with any " " blank spaces 
                if test -f $(echo ${script_module} | sed -e 's/^ *//g;s/ *$//g'); then # Remove leading/trailing spaces and test if config file exists 
                    # make dir(s) if it does not exist
                    [[ -d "./Results" ]] || mkdir "./Results"  # Ensure the './Results' dir exists 
                    [[ -d "./Results/$timestamp" ]] || mkdir "./Results/$timestamp" # Make a dir with the current timestamp 
                    [[ -d "./Results/$timestamp/$script_module_dir" ]] || mkdir "./Results/$timestamp/$script_module_dir"
                    [[ -d "./Results/$timestamp/$script_module_dir/$script_name" ]] || mkdir "./Results/$timestamp/$script_module_dir/$script_name"
                    echo " ~ $ ssh $1 < $script_fullname"
                    ssh $SSH_Options $1 < "$(echo ${script_module} | sed -e 's/^ *//g;s/ *$//g')" > "./Results/$timestamp/$script_module_dir/$script_name/$1__$script_name.txt" 2>/dev/null &
                    sleep 0.4 # Slow things down a bit. Don't DoS yourself with too many ssh connections at once. 
                else
                    echo " X !3rr0r! -- Script NOT Found: $script_module"
                fi 
            fi            
        fi    
	done < "$configFile"
    wait # wait for each host to complete before proceeding. 
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
	echo "!!! ERROR !!! -- Missing parameter."
	echo "Please run birtha.sh as follows: "
	echo "$ ./birtha.sh <user@hostname>"
	echo "$ ./birtha.sh </path/to/hostlist.txt> (*Host list should contain one user@hostname per line.)"
    exit
else 
    reverseit=$(echo $1 | rev) # reverse the order of the string to get the extension first 
    inputs_extension=$(echo $reverseit | cut -d'.' -f1 | rev) # cut on the '.' and reverse the extension back 
    echo $inputs_extension
    if [ "$inputs_extension" == "txt" ]; then 
        echo "possition 1 is a host (txt) file"
        sleep 5
    elif [ "$inputs_extension" == "conf" ]; then 
        echo "possition 1 is a config (conf) file"
        sleep 5
    fi

fi 

if test -z "$2"; then # IF config file param is null, then run the default config 
    #Config file contains instructions to run scripts on remote hosts. 
    configFile="./BirthaConfigs/Default_Modules.conf"
    check_config #Check config file exists function 
else 
    configFile=$2 # set config file location to user input 
    check_config #Check config file exists function 
fi

 
# Script starts running here 
if test -f "$1"; then  # Check If file (hostlist) exists 
    echo_config # Echo the config 
    echo " "
    # echo_ascii1 # Echo ASCII Art
    clear 
    while IFS= read -r line
	do	
	    #call Run_LiveIR function for each host in the hostlist ($1)
        Run_LiveIR $line
        #echo " "		
	done <"$1"
else #Else it must be a userName@hostName/ip     
    Run_LiveIR $1
fi 

echo " "
echo ">> Results can be Found in the 'Results' Folder: "
echo "------------------------------------------------ "
echo " --> './birtha-main/Results/$timestamp/{ *HERE* }'"
echo " "
