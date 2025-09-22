#!/bin/bash

bred='\033[1;31m'
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

playbook="main.yml"

debian_setup() {
    _task "Updating system"
    sudo apt update -y
    sudo apt upgrade -y

    _task "Installing ansible"
    sudo apt install -y ansible

    if dpkg -l ubuntu-server &>/dev/null; then
        playbook="server.yml"
    fi
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
    ubuntu|kali)
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

_task "Running playbook '$playbook'"
ansible-playbook -K -i localhost, -c local $playbook

echo -e "${bold}Done configuring system!$nc"
echo -e "${bylw}Some settings will not take effect until you logout or reboot$nc"
