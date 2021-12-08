 #!/bin/bash
########################
#Variaveis
echo "Nome usuário:"
read usuario
echo "Senha usuario:"
read senhauser
echo "Senha root:"
read senha
echo "Hostname:"
read hostname
echo "Processador microcode (intel-ucode / amd-ucode):"
read proc
echo "Caminho do disco para instalação:"
read disco
echo "Tamanho do swap (ex. 1G):"
read swapsize
uefi="${disco}1"
swap="${disco}2"
linux="${disco}3"
########################
#Configuração Inicial
loadkeys br-abnt2
timedatectl set-ntp true
########################
#Particionamento
wipefs -af $disco
sgdisk -n 1::+300MiB -c 1:"EFI System Partition" -t 1:ef00 $disco
sgdisk -n 2::+$swapsize -c 2:"Swap" -t 2:8200 $disco
sgdisk -n 3::0 -c 3:"Linux" -t 3:8300 $disco
mkfs.fat -F 32 $uefi
mkswap $swap
echo "y" | mkfs.ext4 $linux
mount -o exec $linux /mnt
mkdir /mnt/boot
mount $uefi /mnt/boot
swapon $swap
########################
#Instalação
reflector --country Brazil --sort rate --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware neovim sudo networkmanager alacritty fish firefox xorg-server xorg-xinit xorg-xrandr awesome fontconfig ttf-dejavu
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
########################
#Configuração
genfstab -U /mnt >> /mnt/etc/fstab
#Send the config to chroot enviromnet
cat <<EOF > /mnt/root/install.sh
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i '393 s/^##*//' /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
mkinitcpio -P
echo "root:$senha" | chpasswd
useradd $usuario -s /bin/fish -m -U -G "wheel"
echo "$usuario:$senhauser" | chpasswd
sed -i '85 s/^##*//' /etc/sudoers
systemctl enable NetworkManager
chsh -s /bin/fish
mkdir -p /home/$usuario/.config/awesome
cp /etc/xdg/awesome/rc.lua /home/$usuario/.config/awesome/
mkdir -p mkdir -p /home/$usuario/.config/awesome/themes
cp /usr/share/awesome/themes/* /home/$usuario/.config/awesome/themes/
printf "#!/bin/bash\nsetxkbmap -layout br\nxandr --output Virtual-1 --mode 1680x1050\nexec awesome" > /home/$usuario/.xinitrc
printf 'if status is-login\n    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1\n      exec startx\n   end\nend' > /home/$usuario/.config/fish/config.fish
pacman -S --noconfirm $proc grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit
EOF
chmod +x /mnt/root/install.sh
arch-chroot /mnt /root/install.sh
umount -R /mnt
echo -e "Reinicie para acessar o sistema"
