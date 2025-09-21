#!/bin/bash

bcyn='\033[1;36m'
bylw='\033[1;33m'
bold='\033[1m'
nc='\033[0m'

# TODO: update for other systems

echo -e "${bold}[+] Updating system$nc"
sudo apt update -y
sudo apt upgrade -y

echo -e "${bold}[+] Installing ansible$nc"
sudo apt install -y ansible

echo -e "${bold}[+] Installing required modules$nc"
ansible-galaxy install -r requirements.yml

echo -e "${bold}[+] Running ansible playbook$nc"
ansible-playbook -K -i localhost, -c local main.yml

echo -e "${bold}[+] Cleaning apt$nc"
sudo apt clean -y
sudo apt autoremove -y

echo -e "${bold}Done configuring system!$nc"
echo -e "\n${bylw}Some settings will not take effect until you logout$nc"
