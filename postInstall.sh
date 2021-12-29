#!/bin/bash
sudo pacman -S --noconfirm base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd $HOME
yay -Y --gendb
yay -Y --devel --save
rm -rf yay-bin
git clone https://github.com/ricardaotsi/qtile-nord-dotfiles.git
cd qtile-nord-dotfiles
pacman -S --noconfirm $(awk '{print $1}' requirements)
yay -S picom-jonaburg-git nerd-fonts-hack
yes | pip install psutil
chsh -s /bin/fish
cp .xinitrc $HOME
cp -r .config $HOME
cd $HOME
rm -rf qtile-nord-dotfiles
printf "Install video drivers and reboot"

