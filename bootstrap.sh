#!/bin/sh

if [ ! -d dotfiles ]; then
    git clone https://github.com/bwpge/dotfiles.git
    cd dotfiles
else
    cd dotfiles
    git pull
fi

chmod u+x run.sh && ./run.sh
