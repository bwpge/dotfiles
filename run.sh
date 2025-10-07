#!/bin/bash

bred='\033[1;31m'
cyn='\033[0;36m'
bcyn='\033[1;36m'
bylw='\033[1;33m'
bold='\033[1m'
nc='\033[0m'

_task() {
    echo -e "${bold}[+] $1$nc"
}

_err() {
    echo -e "${bred} error: $1$nc"
}

get_os_id() {
    if [ -f /etc/os-release ]; then
        awk -F= '/^ID=/{print $2}' /etc/os-release | sed 's/"//g'
    elif command sw_vers > /dev/null 2>&1; then
        sw_vers -productName
    fi
}

debian_setup() {
    _task "Updating system"
    sudo apt update -y
    sudo apt upgrade -y

    _task "Installing ansible"
    sudo apt install -y ansible
}

macos_setup() {
    _task "Updating system"
    brew update
    brew upgrade

    _task "Installing ansible"
    brew install ansible
}

os_id="$(get_os_id | tr '[:upper:]' '[:lower:]')"
_task "Running setup for OS ID '${os_id}'"

case "$os_id" in
    debian|ubuntu|kali)
        debian_setup
        ;;
    macos)
        macos_setup
        ;;
    *)
        _err "unsupported OS '$os_id'"
        exit 1
        ;;
esac

_task "Installing required modules"
ansible-galaxy install -r requirements.yml

chmod u+x bin/dotfiles
bin/dotfiles install &> /dev/null

echo -e "\n${cyn}Finished setting up! Run$nc\n"
echo -e "${bcyn}    dotfiles help$nc"
echo -e "\n${cyn}for more information$nc"
