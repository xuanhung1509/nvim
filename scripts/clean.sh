#!/bin/bash

echo -n "Cleaning neovim... "

rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

echo "done."
