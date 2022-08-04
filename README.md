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

## Optimisation
It is interesting to start using the script at midnight, the calculation technique will only be 100% effective from one cycle until midnight (depending on your timezone). 


## Disclaimer
This script is given as is. I can't be responsible for modifications, loss of access or misconfiguration made on your side. You have to make sure that your configurations work or that your script is executable. Make a test before putting in production with a crontab.

# Testing
To validate a distribution/distribution version, please insert a pull request.
| Distribution | Compatible ? |
|:------------:|:------------:|
|   Debian 10  |      yes     |
|   Debian 11  |      yes     |
| Ubuntu 20.04 |      yes     |
|  Centos 7/8  |      no      |

# Special thanks
- [@empty-system](https://github.com/empty-system) For help on some optimizations
- [@Legendary4226](https://github.com/Legendary4226) For fixing problems that occur at specific times. Quality control.
