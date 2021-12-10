#!/bin/bash
sudo pacman -S --noconfirm fish alacritty firefox xorg-server xorg-xinit xorg-xrandr awesome fontconfig ttf-dejavu git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd $HOME
yay -Y --gendb
yay -Y --devel --save
yay -S picom-jonaburg-git
git clone https://github.com/ricardaotsi/archisntall
chsh -s /bin/fish

