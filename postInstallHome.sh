#!/bin/fish
####################################################
##Install Yay
sudo pacman -Sy archlinux-keyring
sudo pacman -S --noconfirm base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd $HOME
yay -Y --gendb
yay -Y --devel --save
rm -rf yay-bin
###################################################
##Install requirements
sudo pacman -S --noconfirm $(awk '{print $1}' requirementsHome)
###################################################
##Enable services
sudo systemctl enable sshd
sudo systemctl enable cronie
###################################################
##Configure and enable tigervnc
mkdir /home/ricardo/.vnc
printf ":1=ricardo\n" | sudo tee -a /etc/tigervnc/vncserver.users
printf "session=plasma\ngeometry=1920x1080" > ~/.vnc/config
printf "100senha" | vncpasswd -f > /home/ricardo/.vnc/passwd
chown -R ricardo:ricardo /home/ricardo/.vnc
chmod 0600 /home/ricardo/.vnc/passwd
sudo systemctl enable vncserver@:1.service
###################################################
##Startx
printf "export DESKTOP_SESSION=plasma\nexec startplasma-x11" > ~/.xinitrc
###################################################
##Autologin
sudo mkdir /etc/systemd/system/getty@tty1.service.d
printf "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin ricardo --noclear %%I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
###################################################
##Mount sdb1
sudo mkdir /mnt/data
sudo chown -R ricardo:ricardo /mnt/data
printf "/dev/sdb1	/mnt/data	ext4	defaults	0 0\n" | sudo tee -a /etc/fstab
###################################################
##Copy config
git clone https://github.com/ricardaotsi/qtile-nord-dotfiles.git
cd qtile-nord-dotfiles
cp -r .local ~/
cp -r .byobu ~/
cp '*rc' ~/.config
cp -r .config/fish ~/.config
cd $HOME
rm -rf qtile-nord-dotfiles
