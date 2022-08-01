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
ad_logfile=/var/log/anti-ddos.log           # Logfile for software
discord_webhook=""                          # Discord webhook URL for Discord logging (optionnal)
################################


#################################################################################################
################################## Do not edit below this line ##################################
#################################################################################################

if [ "$EUID" -ne 0 ]
  then echo "ERROR: This script can only be run as root"
  exit
fi
echo -ne '                         (1%)\r'

# This is a way to calculate the maximum number of requests per hour for the actual cycle.
current_cycle=$(date +%H)
mutiplicator=1
if ! [ current_cycle == 0 ]; then
    multiplicator=$current_cycle
fi
max_requests=$(($max_connexions_per_hour*$multiplicator))
echo -ne '                         (3%)\r'
cat $logfile | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -50 >> $counting
sleep 5
echo -ne '#####                     (33%)\r'
while IFS=" " read -r occ ip; do
                if [[ $occ -gt $max_requests ]]; then
                    echo "$ip" >> $tempfile
                fi
            done<$counting

sleep 5
echo -ne '#############             (66%)\r'
if ! [[ -f $tempfile ]];then
    echo "Great news, no DDOS detected ! :)"    
    exit
fi

timecode=$(date +%d-%m-%Y--%H:%M)
action=false

# Banning the IP from the selected firewall.
if [ $firewall == "iptables" ]; then
    while IFS= read -r line
    do
        if ! [[ $(iptables -S | grep $line) ]] ; then
            sudo iptables -I INPUT -s $line -j DROP
            echo "[ $timecode ] : banned ip $line" >> $ad_logfile
            action=true
        fi
    done < "$tempfile"
elif [ $firewall == "ufw" ]; then
    if [[ $(ufw status | grep "inactive") ]] ; then
            echo "[ $timecode ] : WARNING : UFW is inactive" >> $ad_logfile
        fi
    while IFS= read -r line
    do
        if ! [[ $(ufw status | grep $line) ]] ; then
            sudo ufw insert 1 deny from $line to any
            echo "[ $timecode ] : banned ip $line" >> $ad_logfile
            action=true
        fi
    done < "$tempfile"
else
    echo "ERROR : Wrong option in \"firewall\""
    rm $counting
    rm $tempfile
    exit
fi
echo -ne '###################       (89%)\r'

# This is a way to check if the variable is empty or not. Sending to logfile the output and if set, send to Discord a notification.
if [ $action=true ]; then
    if ! [ -z "$discord_webhook" ]; then
    curl -H "Content-Type: application/json" -d '{"username": "IP blocking", "embeds":[{"title":"New IP(s) blocked","description":"Check the logfile on your server for more informations.","color":14177041}]}' "$discord_webhook"
    fi
fi

# Removing the temporary files that were created.
rm $counting
rm $tempfile
echo -ne '#######################   (100%)\r'