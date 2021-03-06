#!/bin/bash
########################
#Variaveis
echo "Nome usuário:"
read usuario
echo "Senha:"
read senha
echo "Hostname:"
read hostname
echo "Processador microcode (intel-ucode / amd-ucode):"
read proc
echo "Caminho do disco para instalação:"
read disco
echo "Tamanho do swap (ex. 1G):"
read swapsize
echo "Tamanho do root (ex. 100G):"
read rootsize
uefi="${disco}1"
swap="${disco}2"
linux="${disco}3"
home="${disco}4"
########################
#Configuração Inicial
loadkeys br-abnt2
timedatectl set-ntp true
########################
#Particionamento
wipefs -af $disco
sgdisk -n 1::+300MiB -c 1:"EFI System Partition" -t 1:ef00 $disco
sgdisk -n 2::+$swapsize -c 2:"Swap" -t 2:8200 $disco
sgdisk -n 3::+$rootsize -c 3:"Linux" -t 3:8300 $disco
sgdisk -n 4::0 -c 4:"Home" -t 4:8300 $disco
mkfs.fat -F 32 $uefi
mkswap $swap
echo "y" | mkfs.ext4 $linux
echo "y" | mkfs.ext4 $home
mount -o exec $linux /mnt
mkdir /mnt/home
mount $home /mnt/home
mkdir /mnt/boot
mount $uefi /mnt/boot
swapon $swap
########################
#Instalação
printf 'Server = http://archlinux.c3sl.ufpr.br/$repo/os/$arch' > /etc/pacman.d/mirrorlist
#reflector --country Brazil --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Sy --noconfirm archlinux-keyring
pacstrap /mnt base linux linux-firmware neovim sudo networkmanager git fish
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
useradd $usuario -s /bin/fish -m -U -G "wheel"
echo "$usuario:$senha" | chpasswd
sed -i '85 s/^##*//' /etc/sudoers
systemctl enable NetworkManager
pacman -S --noconfirm intel-ucode grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF
chmod +x /mnt/root/install.sh
arch-chroot /mnt /root/install.sh
cp /root/archinstall/postInstallHome.sh /mnt/home/$usuario
cp /root/archinstall/requirementsHome /mnt/home/$usuario
umount -R /mnt
echo -e "Reinicie para acessar o sistema"
