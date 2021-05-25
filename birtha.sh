#!/bin/bash
# ABOUT:
#  This Script will perform Remote IR on Unix/Ubuntu based Hosts using ssh keypair authentication  
#       Last Updated: 12.8.19
#       Author: AJ
# USAGE:
#  Modules can be chosen in the "./Modules.conf" file. Simply comment '#' out lines you don't want to run. 
#  example: $ ./birtha.sh <User@HostName>
#  example: $ ./birtha.sh <User@IPaddr>
#  example: $ ./birtha.sh </path/to/hostlist.txt>   (*Host list should contain one 'User@Hostname' per line.)
#  example: $ ./birtha.sh </path/to/hostlist.txt>  [./Modules/Modules.conf]

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
                echo "RUN_MODULE: $line"                
            fi
        fi 
	done < "$configFile"
    sleep 2
}

check_config(){
    #Check Config file exists  
    if test -z "$configFile"; then 
        echo "!!! ERROR !!! -- Config File Not Found!"
        exit  
    fi
}

### MAIN SSH Function ### 
### This function does all the heavy lifting by running the scripts on remote hosts and reporting the results  
Run_LiveIR() {   
    while IFS= read -r line
	do	
        newline1=$(echo $line | cut -f4 -d'/') #remove path from string
        newline2=$(echo $newline1 | cut -f1 -d'.') #remove .sh from script name 
        #if line is not a comment 
        if grep -q "\#" <<< "$line"; then #if commented "#" then skip 
            continue #basically do nothing... 
        else
            ##Skip config lines with any " " blank spaces 
            if !(test -z "${line// }"); then  
                if test -f $(echo ${line} | sed -e 's/^ *//g;s/ *$//g'); then # Remove leading/trailing spaces and test if config file exists 
                    #make dir if it does not exist
                    [[ -d "./Results" ]] || mkdir "./Results"
                    [[ -d "./Results/$timestamp" ]] || mkdir "./Results/$timestamp"
                    [[ -d "./Results/$timestamp/$newline2" ]] || mkdir "./Results/$timestamp/$newline2"
                    echo " ~ $ ssh $1 < $newline1"
                    ssh $1 < "$(echo ${line} | sed -e 's/^ *//g;s/ *$//g')" > "./Results/$timestamp/$newline2/$1__$newline2.txt" -q -o "StrictHostKeyChecking=no" -o "PasswordAuthentication=no" 2>/dev/null &
                else
                    echo "!!! ERROR !!! $1 < $line"
                fi 
            fi
        fi    
	done < "$configFile"
    wait # wait for each host to complete before proceeding. 
}

#
#Run_Analysis() { # examp. cat ./Results/Fri_26_Feb_2021_11.03.32_PM_CST/cat_passwd/*
#    #while IFS= read -r line
#        cat "./Results/$timestamp/$line/"
#    #done < "$configFile"
#}


# Check if run argument is missing, if it is missing error and exit 
if test -z "$1"; then # $1 is a positional parameter
	# then $1 is null 
	echo "!!! ERROR !!! -- Missing parameter."
	echo "Please run laNSA.sh as follows: "
	echo "$ ./laNSA.sh <user@hostname>"
	echo "$ ./laNSA.sh </path/to/hostlist.txt> (*Host list should contain one user@hostname per line.)"
    exit
fi 

if test -z "$2"; then # IF config file param is null, then run the default config 
    #Config file contains instructions to run scripts on remote hosts. 
    configFile="./Modules/Default_Modules.conf"
    check_config #Check config file exists function 
else 
    configFile=$2 # set config file location to user input 
    check_config #Check config file exists function 
fi

# Get the current time and format it into a directory name to hold the script's results 
timestamp=$(date|tr ' ' '_' |tr ':' '.') #replace the spaces in date to "_" &  ':' to '.'
 
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
echo " --> './birtha/Results/$timestamp/{ *HERE* }'"
echo " "
echo " "
