#!/bin/bash
########################
#Variaveis
swapsize="1G"
disco="/dev/vda"
uefi="/dev/vda1"
swap="/dev/vda2"
linux="/dev/vda3"
hostname="archdesktop"
proc=""
########################
#Configuração Inicial
loadkeys br-abnt2
timedatectl set-ntp true
########################
#Particionamento
wipefs --all $disco
sgdisk -n 1::+300MiB -c 1:"EFI System Partition" -t 1:ef00 $disco
sgdisk -n 2::+$swapsize -c 2:"Swap" -t 2:8200 $disco
sgdisk -n 3::0 -c 3:"Linux" -t 3:8300 $disco
mkfs.fat -F 32 $uefi
mkswap $swap
mkfs.ext4 $linux
mount -o exec $linux /mnt
mkdir /mnt/boot
mount $uefi /mnt/boot
swapon $swap
########################
#Instalação
reflector --country Brazil --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware
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
passwd
pacman -S $proc grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/etc/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit
EOF
chmod +x /mnt/root/install.sh
arch-chroot /mnt /root/install.sh
umount -R /mnt
echo -e "Reinicie para acessar o sistema"
