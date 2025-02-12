#!/bin/bash -e

git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme
./install.sh --tweaks nord darker rimless
rm -rf Graphite-gtk-theme