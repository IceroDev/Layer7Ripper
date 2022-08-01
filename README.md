# Layer7Ripper 
A script to minimize denial of service attacks using Layer 7. This script will work for low level attacks using a few IP addresses.

## How does it works ?
The program will analyze your log file and see the number of occurrences of the IP address in this same file. If the number of accepted requests per hour is exceeded the program will block the IP address via the firewall you have chosen.

This program works in case the attacker uses only one or a limited number of addresses. In case you are a victim of a botnet attack, there is little chance that this script will work quickly because too many addresses will be present with a limited number of occurrences.

## Configuration
- **logfile** is the parameter that selects the file to be analyzed.
- **max_connexions_per_hour** is the parameter that defines the maximum number of requests an IP address can make.
- **firewall** is the parameter choosing the firewall to use (by default iptables) ufw|iptables.
- **counting** is the location of a temporary file for counting occurrences.
- **tempfile** is the location of a temporary file to list the ip's to ban.
- **ad_logfile** is the location of the general log file of the program.
- **discord_webhook** is an optional parameter that allows you to send an alert when a new ip is added to the firewall on the Discord software.

### How to create a Discord webhook ?
1) Click on the "edit show" gear when you move your mouse over the show where you want to receive notifications.
2) Click on "Integrations".
3) Click on "Create a webhook" and enter the information you want.
4) Click on "Copy webhook URL" and enter it between the quotes of the parameter on the script.

## Installation

### Downloading the script
Be careful, you will have to create the crontab yourself.
```
wget https://raw.githubusercontent.com/IceroDev/Layer7Ripper/main/L7Ripper.sh
```
### Full installation script
You'll still have to change values on the program in /etc/l7ripper/program
```
wget https://raw.githubusercontent.com/IceroDev/Layer7Ripper/main/install.sh
```

