#!/bin/fish
sudo pacman -Sy archlinux-keyring
sudo pacman -S --noconfirm base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd $HOME
yay -Y --gendb
yay -Y --devel --save
rm -rf yay-bin
sudo pacman -S --noconfirm (awk '{print $1}' requirementsHome)
sudo systemctl enable sshd
sudo systemctl enable cronie
printf "export DESKTOP_SESSION=plasma\nexec startplasma-x11" > ~/.xinitrc
git clone https://github.com/ricardaotsi/qtile-nord-dotfiles.git
cp qtile-nord-dotfiles/.byobu ~/
cp qtile-nord-dotfiles/.config/fish ~/.config/
rm -rf qtile-nord-dotfiles
sudo mkdir /etc/systemd/system/getty@tty1.service.d
sudo printf "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin ricardo --noclear %I $TERM" > /etc/systemd/system/getty@tty1.service.d/override.conf
sudo mkdir /mnt/data
sudo chown -R ricardo:ricardo /mnt/data
sudo printf "/dev/sdb1	/mnt/data	defaults	0 0\n" >> /etc/fstab
cat /usr/share/xsessions/
read sessao
printf ":1 ricardo\n" >> /etc/tigervnc/vncserver.users
printf "session=$sessao\ngeometry=1920x1080" > ~/.vnc/config
vncpasswd
sudo systemctl enable vncserver@:1.service
