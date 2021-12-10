#!/bin/bash
sudo pacman -S --noconfirm fish alacritty firefox xorg-server xorg-xinit xorg-xrandr awesome fontconfig ttf-dejavu
chsh -s /bin/fish
mkdir -p /home/$usuario/.config/awesome
cp /etc/xdg/awesome/rc.lua /home/$usuario/.config/awesome/
mkdir -p /home/$usuario/.config/awesome/themes
cp -R /usr/share/awesome/themes/* /home/$usuario/.config/awesome/themes/
printf "#!/bin/bash\nsetxkbmap -layout br\nxandr --output Virtual-1 --mode 1680x1050\nexec awesome" > /home/$usuario/.xinitrc
printf 'if status is-login\n    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1\n      exec startx\n   end\nend' > /home/$usuario/.config/fish/config.fish
