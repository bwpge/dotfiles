#!/bin/sh

set -euo pipefail

dfdir="/opt/dotfiles"
if [ ! -w "/opt" ]; then
    dfdir="$HOME/.dotfiles"
fi

if [ ! -d "$dfdir" ]; then
    git clone https://github.com/bwpge/dotfiles.git "$dfdir"
fi

$dfdir/install.sh "$dfdir"
