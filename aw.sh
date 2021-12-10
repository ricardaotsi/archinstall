#!/bin/bash
sudo pacman -S --noconfirm fish alacritty firefox xorg-server xorg-xinit xorg-xrandr awesome fontconfig ttf-dejavu picom git base-devel yay
sudo chsh -s /bin/fish $USER
mkdir -p /home/$USER/.config/awesome
cp /etc/xdg/awesome/rc.lua /home/$USER/.config/awesome/
mkdir -p /home/$USER/.config/awesome/themes
cp -R /usr/share/awesome/themes/* /home/$USER/.config/awesome/themes/
mkdir -p /home/$USER/.conig/alacritty
cp /usr/share/doc/alacritty/example/alacritty.yml /home/$USER/.config/alacritty/
printf "#!/bin/bash\nsetxkbmap -layout br\nxrandr --output Virtual-1 --mode 1680x1050\npicom -f &\nexec awesome" > /home/$USER/.xinitrc
printf 'if status is-login\n    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1\n      exec startx\n   end\nend' > /home/$USER/.config/fish/config.fish
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
