#!/bin/sh

dfpath="$HOME/.dotfiles"

if [ ! -d "$dfpath" ]; then
    git clone https://github.com/bwpge/dotfiles.git "$dfpath"
    cd "$dfpath"
else
    cd "$dfpath"
    git pull
fi

./run.sh
