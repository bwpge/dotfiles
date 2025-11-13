#!/bin/bash

set -e

if command dotfiles &>/dev/null; then
    echo "dotfiles already installed"
    exit 0
fi

dfpath="/opt/dotfiles"
dfconf="/etc/dotfiles.conf"

BRED='\033[1;31m'
CYAN='\033[0;36m'
BCYAN='\033[1;36m'
BGREEN='\033[1;32m'
NC='\033[0m'

__sudo="sudo"
if [ "$(id -u)" -eq 0 ]; then
    __sudo=""
fi

_task() {
    echo -e "${BGREEN}[+] $1$NC"
}

_err() {
    echo -e "${BRED} error: $1$NC"
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
    $__sudo apt update -y
    $__sudo apt upgrade -y

    _task "Installing ansible"
    $__sudo apt install -y ansible
}

macos_setup() {
    _task "Updating system"
    brew update
    brew upgrade

    _task "Installing ansible"
    brew install ansible
}

common_setup() {
    src="$dfpath/bin/dotfiles"
    target="/usr/local/bin/dotfiles"

    if [ ! -f "$src" ]; then
        _err "error: could not determine path to dotfiles script" >&2
        exit 1
    fi

    echo "creating link: $src -> $target"
    $__sudo ln -sf $src $target

    echo "creating config file: $dfconf"
    $__sudo touch $dfconf
}

os_id="$(get_os_id | tr '[:upper:]' '[:lower:]')"
_task "Running setup for OS ID '${os_id}'"

case "$os_id" in
    debian|ubuntu|kali|pop)
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

common_setup

_task "Installing required modules"
ansible-galaxy install -r "$dfpath/requirements.yml"

echo -e "\n${CYAN}Finished setting up! Run$NC\n"
echo -e "${BCYAN}    dotfiles help$NC"
echo -e "\n${CYAN}for more information$NC"
