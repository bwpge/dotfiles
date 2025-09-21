#!/bin/sh

if [ ! -d dotfiles ]; then
    git clone https://github.com/bwpge/dotfiles.git
fi

cd dotfiles &&\
chmod u+x run.sh &&\
./run.sh
