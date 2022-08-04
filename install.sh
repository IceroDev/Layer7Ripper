#!/bin/bash

#     ___        _   _       ____________ _____ _____ 
#    / _ \      | | (_)      |  _  \  _  \  _  /  ___|
#   / /_\ \_ __ | |_ _ ______| | | | | | | | | \ `--. 
#   |  _  | '_ \| __| |______| | | | | | | | | |`--. \
#   | | | | | | | |_| |      | |/ /| |/ /\ \_/ /\__/ /
#   \_| |_/_| |_|\__|_|      |___/ |___/  \___/\____/ 
#     Block spamming IP address for simple L7 DDOS  
#               Developed by Jean Staffe               

echo -e "How often should the program check for a DDOS attack?\n\n1) Every minutes\n2) Every 5 minutes\n3) Every 10 minutes\n4) Every 30 minutes\n5 Every hours\n"
read -rp "(1/5) ~" -e qvvf

crontab_line=""

if [ $qvvf == "1" ]; then
    crontab_line="* * * * * /etc/l7ripper/program >/dev/null 2>&1"
fi
if [ $qvvf == "2" ]; then 
    crontab_line="*/5 * * * * /etc/l7ripper/program >/dev/null 2>&1"
fi
if [ $qvvf == "3" ]; then 
    crontab_line="*/10 * * * * /etc/l7ripper/program >/dev/null 2>&1"
fi
if [ $qvvf == "4" ]; then 
    crontab_line="*/30 * * * * /etc/l7ripper/program >/dev/null 2>&1"
fi
if [ $qvvf == "5" ]; then 
    crontab_line="0 * * * * /etc/l7ripper/program >/dev/null 2>&1"
fi

mkdir /etc/l7ripper
wget -O /etc/l7ripper/program https://raw.githubusercontent.com/IceroDev/Layer7Ripper/main/L7Ripper.sh
chmod +x /etc/l7ripper/program
sleep 1
(crontab -u $(whoami) -l; echo "$crontab_line" ) | crontab -u $(whoami) -
