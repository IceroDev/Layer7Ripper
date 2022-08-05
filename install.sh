#!/bin/bash

#     ___        _   _       ____________ _____ _____ 
#    / _ \      | | (_)      |  _  \  _  \  _  /  ___|
#   / /_\ \_ __ | |_ _ ______| | | | | | | | | \ `--. 
#   |  _  | '_ \| __| |______| | | | | | | | | |`--. \
#   | | | | | | | |_| |      | |/ /| |/ /\ \_/ /\__/ /
#   \_| |_/_| |_|\__|_|      |___/ |___/  \___/\____/ 
#     Block spamming IP address for simple L7 DDOS  
#               Developed by Jean Staffe               

mkdir /etc/l7ripper
wget -O /etc/l7ripper/program https://raw.githubusercontent.com/IceroDev/Layer7Ripper/main/L7Ripper.sh
chmod +x /etc/l7ripper/program
echo -e "[Unit]\nDescription=starting an antiddos service\n\n[Service]\nExecStart=/etc/l7ripper/program\nRestart=always\nRestartSec=30s\n\n[Install]\nWantedBy=multi-user.target" > /usr/lib/systemd/system/layer7ripper
systemctl enable layer7ripper
systemctl start layer7ripper
