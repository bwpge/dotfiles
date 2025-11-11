#!/bin/sh

set -euo pipefail

dfpath="/opt/dotfiles"

__sudo="sudo"
if [ "$(id -u)" -eq 0 ]; then
    __sudo=""
fi

if [ ! -d "$dfpath" ]; then
    $__sudo git clone https://github.com/bwpge/dotfiles.git "$dfpath"
fi

$dfpath/install.sh
