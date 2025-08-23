#!/bin/bash

bcyn='\033[1;36m'
bylw='\033[1;33m'
bold='\033[1m'
nc='\033[0m'

_confirm() {
    while true; do
        echo -ne "${bold}$1$nc [y/N]: "
        read -r yn
        case $yn in
            [Yy] ) return 0;;
            [Nn]|'' ) return 1;;
            *) echo "Invalid response. Please answer y or n.";;
        esac
    done
}

_countdown() {
    seconds=5
    for ((i=seconds; i>0; i--)); do
        echo -ne "\r${bylw}$1 in $i seconds...$nc "
        sleep 1
    done
    echo
}

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

if [ $? = 0 ]; then
    echo -e "\n${bcyn}Some settings will not take effect until you logout$nc"

    if command -v xfce4-session-logout &> /dev/null; then
        if _confirm "Do you want to logout now?"; then
            _countdown "Logging out"
            xfce4-session-logout --logout
            exit 0
        fi
    fi
fi
