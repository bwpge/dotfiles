#!/bin/bash

set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
    echo "error: git is required to bootstrap dotfiles" >&2
    exit 1
fi

dfdir="$HOME/.dotfiles"

if [ ! -d "$dfdir" ]; then
    git clone https://github.com/bwpge/dotfiles.git "$dfdir"
fi

"$dfdir/install.sh" "$dfdir"
