#!/bin/bash

set -euo pipefail

if command -v dotfiles >/dev/null 2>&1; then
    echo "dotfiles already installed"
    exit 0
fi

BRED='\033[1;31m'
CYAN='\033[0;36m'
BCYAN='\033[1;36m'
BGREEN='\033[1;32m'
BYEL='\033[1;33m'
NC='\033[0m'

_task() {
    printf '%b\n' "${BGREEN}[+] $1${NC}"
}

_err() {
    printf '%b\n' "${BRED}error: $1${NC}" >&2
}

if [ $# -ne 1 ]; then
    printf 'usage: %s <INSTALL_DIR>\n' "$0" >&2
    exit 1
fi

dfdir="$1"
if [ ! -d "$dfdir" ]; then
    _err "invalid install directory '$dfdir'"
    exit 1
fi
dfdir="$(cd "$dfdir" && pwd)"
_task "Using install directory: $dfdir"

get_os_id() {
    if [ -f /etc/os-release ]; then
        awk -F= '/^ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release
    elif command -v sw_vers >/dev/null 2>&1; then
        sw_vers -productName
    fi
}

debian_setup() {
    local sudo=""
    if [ "$(id -u)" -ne 0 ]; then
        sudo="sudo"
    fi

    _task "Refreshing package index"
    $sudo apt update

    _task "Installing ansible"
    $sudo apt install -y ansible
}

macos_setup() {
    _task "Refreshing package index"
    brew update

    _task "Installing ansible"
    brew install ansible
}

common_setup() {
    src="$dfdir/bin/dotfiles"
    target_dir="$HOME/.local/bin"
    target="$target_dir/dotfiles"

    if [ ! -f "$src" ]; then
        _err "could not determine path to dotfiles script"
        exit 1
    fi

    echo "ensure directory exists: $target_dir"
    mkdir -p "$target_dir"

    echo "creating link: $src -> $target"
    ln -sf "$src" "$target"
}

os_id="$(get_os_id | tr '[:upper:]' '[:lower:]')"
_task "Running setup for OS ID '${os_id}'"

case "$os_id" in
    debian|ubuntu|kali|pop|linuxmint)
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
ansible-galaxy install -r "$dfdir/requirements.yml"

if ! command -v dotfiles >/dev/null 2>&1; then
    printf '\n%b\n' "${BYEL}warning:${NC} '$HOME/.local/bin' is not on your PATH" >&2
    printf '%b\n' "add it to your shell profile, e.g.:" >&2
    printf '%b\n' '    export PATH="$HOME/.local/bin:$PATH"\n' >&2
fi

printf '\n%b\n\n' "${CYAN}Finished setting up! Run${NC}"
printf '%b\n' "${BCYAN}    dotfiles --help${NC}"
printf '\n%b\n' "${CYAN}for more information${NC}"
