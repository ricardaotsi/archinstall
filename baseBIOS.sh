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
swap="${disco}1"
linux="${disco}2"
########################
#Configuração Inicial
loadkeys br-abnt2
timedatectl set-ntp true
########################
#Particionamento
wipefs -af $disco
sgdisk -n 1::+$swapsize -c 1:"Swap" -t 1:8200 $disco
sgdisk -n 2::0 -c 2:"Linux" -t 2:8300 $disco
mkswap $swap
echo "y" | mkfs.ext4 $linux
mount -o exec $linux /mnt
swapon $swap
########################
#Instalação
reflector --country Brazil --sort rate --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware neovim sudo networkmanager git
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
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
echo "$hostname" > /etc/hostname
mkinitcpio -P
echo "root:$senha" | chpasswd
useradd $usuario -s /bin/bash -m -U -G "wheel"
echo "$usuario:$senhauser" | chpasswd
sed -i '85 s/^##*//' /etc/sudoers
systemctl enable NetworkManager
pacman -S --noconfirm $proc grub
grub-install --target=i386-pc $disco
grub-mkconfig -o /boot/grub/grub.cfg
EOF
chmod +x /mnt/root/install.sh
arch-chroot /mnt /root/install.sh
cp /root/archinstall/awesome.sh /mnt/home/$usuario
umount -R /mnt
echo -e "Reinicie para acessar o sistema"
