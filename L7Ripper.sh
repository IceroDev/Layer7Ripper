#!/bin/bash

#     ___        _   _       ____________ _____ _____ 
#    / _ \      | | (_)      |  _  \  _  \  _  /  ___|
#   / /_\ \_ __ | |_ _ ______| | | | | | | | | \ `--. 
#   |  _  | '_ \| __| |______| | | | | | | | | |`--. \
#   | | | | | | | |_| |      | |/ /| |/ /\ \_/ /\__/ /
#   \_| |_/_| |_|\__|_|      |___/ |___/  \___/\____/ 
#     Block spamming IP address for simple L7 DDOS  
#               Developed by Jean Staffe                                               
                                                  

######## Configurations ########
logfile=/var/log/nginx/access.log           # Link to the logfile to check.
max_connexions_per_hour=10000               # Maximum allowed connexions on 1h before beiing banned.
firewall=iptables                           # Used Firewall (ufw|iptables).
counting=/tmp/anti-ddos_counting.tmp        # Temporary logfile localisation, will be deleted at the end of script.
tempfile=/tmp/anti-ddos.tmp                 # Temporary logfile localisation, will be deleted at the end of script.
discord_webhook=""                          # Discord webhook URL for Discord logging (optionnal)
################################


#################################################################################################
################################## Do not edit below this line ##################################
#################################################################################################

if [ "$EUID" -ne 0 ]
  then echo "ERROR: This script can only be run as root"
  exit
fi

if ! command -v sudo &> /dev/null
then
    echo "sudo could not be found, installing"
    apt install sudo
fi

if ! command -v $firewall &> /dev/null
then
    echo "$firewall could not be found, installing"
    apt install "$firewall"
fi

if ! command -v curl &> /dev/null
then
    echo "curl could not be found, installing"
    apt install curl
fi


# This is a way to calculate the maximum number of requests per hour for the actual cycle.
current_cycle=$(($(date +%k) + 0))
mutiplicator=1
if ! [ current_cycle == "00" ]; then
    multiplicator=$current_cycle
fi
max_requests=$(($max_connexions_per_hour*$multiplicator))

# This is a way to secure a possible failing of the multiplicator.
if [ $max_requests -lt $max_connexions_per_hour ]; then
    max_requests=$max_connexions_per_hour
fi


# Taking the first column of the logfile, sorting it, counting the number of occurences, sorting it again and taking the first 50 lines.
cat $logfile | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -50 >> $counting
sleep 5


# Reading the file and if the number of occurences is greater than the maximum allowed, it will write the IP in the temporary file.
while IFS=" " read -r occ ip; do
    if [[ $occ -gt $max_requests ]]; then
        echo "$ip" >> $tempfile
    fi
done<$counting
sleep 5


# Checking if the file exists. If it does not, it will exit the script.
if ! [[ -f $tempfile ]];then
    echo "Great news, no DDOS detected ! :)"
    rm $counting
    exit
fi

action="no"

# Banning the IP from the selected firewall.
if [ $firewall == "iptables" ]; then
    while IFS= read -r iptoban
    do
        if ! [[ $(iptables -S | /bin/grep $iptoban) ]] ; then
            sudo iptables -I INPUT -s $iptoban -m comment --comment "DDOS detected ip. Banned by Layer7Ripper" -j DROP
            echo "banned ip $iptoban"
            action="yes"
        fi
    done<"$tempfile"
elif [ $firewall == "ufw" ]; then
    if [[ $(ufw status | /bin/grep "inactive") ]] ; then
        echo "WARNING : UFW is inactive"
    fi
    while IFS= read -r iptoban
    do
        if ! [[ $(ufw status | /bin/grep $iptoban) ]] ; then
            sudo ufw insert 1 deny from $iptoban to any comment "DDOS detected ip. Banned by Layer7Ripper"
            echo "banned ip $iptoban"
            action="yes"
        fi
    done<"$tempfile"
else
    echo "ERROR : Wrong option in \"firewall\""
    rm $counting
    rm $tempfile
    exit
fi


# This is a way to check if the variable is empty or not. Sending to logfile the output and if set, send to Discord a notification.
if [ $action == "yes" ]; then
    if ! [ -z "$discord_webhook" ]; then
        blocked_ip=$(paste -s -d ' ' $tempfile)
        curl -H "Content-Type: application/json" -d '{"username": "IP blocking", "embeds":[{"title":"New IP(s) blocked","description":"'"$blocked_ip"'","color":9899534}]}' "$discord_webhook"
    fi
fi

# Removing the temporary files that were created.
rm $counting
rm $tempfile
