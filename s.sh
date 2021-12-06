#!/bin/bash
########################
#Variaveis
swapsize=1
disco="/dev/sda"
uefi="/dev/sda1"
swap="/dev/sda2"
linux="/dev/sda3"
hostname="archdesktop"
proc="intel-ucode"

########################
#Configuração Inicial
loadkeys br-abnt2
timedatectl set-ntp true

########################
#Particionamento
lsblk -d
#echo -e "Qual o disco para particionar?"
#read disco
echo -e "Apagando Disco"
wipefs $disco
echo -e "Creating UEFI Boot Partition"
sgdisk -n 1::+300MiB -c 1:"EFI System Partition" -t 1:ef00 $disco
sgdisk -n 2::+$swapsize -c 2:"Swap" -t 2:8200 $disco
sgdisk -n 3::0 -c 3:"Linux" -t 3:8300 $disco
mkfs.fat -F 32 $uefi
mkswap $swap
mkfs.ext4 $linux
mount $linux /mnt
mount $uefi /mnt/boot
swapon $swap

########################
#Instalação
reflector --country Brazil --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware

########################
#Configuração
reflector --country Brazil --latest 5 --sort rate --save /mnt/etc/pacman.d/mirrorlist
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i '393 s/^##*//' /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
#echo -e "Qual o hostname?"
#read hn
#echo $hn >> /etc/hostname
mkinitcpio -P
passwd
#echo -e "Qual o processador? (i)ntel ou (a)md"
#read proc
#case $proc in
#	i)
#		pacman -S intel-ucode
#		;;
#	a)
#		pacman -S amd-ucode
#		;;
#######################
#Boot Loader
pacman -S $proc grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/etc/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit
umount -R /mnt
echo -e "Reinicie para acessar o sistema"
