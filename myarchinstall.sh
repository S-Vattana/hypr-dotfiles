#!/bin/bash
echo "!!Important!!"
echo "Please use cfdisk to partition first before run"
echo "Just partition not format"
echo "also please check disk variables. Make sure it correct"
echo "use at your own risk"
read -p "Wanna start this sucky script ;) Type: yes to confirm: " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Script Cancel."
    exit 1
fi

# Set Variables
HOSTNAME="Tsukuyomiツ"
DISK="/dev/nvme0n1"
EFI_PART="${DISK}p1"
SWAP_PART="${DISK}p2"
ROOT_PART="${DISK}p3"
TIMEZONE="Asia/Phnom_Penh"

# enable ParallelDownload
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# Format Partition
mkfs.vfat -F 32 "$EFI_PART"
mkswap "$SWAP_PART"
mkfs.ext4 "$ROOT_PART"

# Mount partition
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi
swapon "$SWAP_PART"

# Pacstrap
pacstrap /mnt base linux linux-firmware intel-ucode

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new system
arch-chroot /mnt /bin/bash <<EOF

hostnamectl hostname "$HOSTNAME"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8' /etc/locale.gen
locale-gen
echo LANG="en_US.UTF-8" >> /etc/locale.conf
localectl set-keymap us
timedatectl set-timezone "$TIMEZONE"
timedatectl set-ntp TRUE
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
sed -i '/^ParallelDownloads = 5/a ILoveCandy' /etc/pacman.conf

pacman -Sy networkmanager vim grub efibootmgr git unzip sudo wget ntfs-3g --noconfirm
systemctl enable NetworkManager

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch\ Linux
grub-mkconfig -o /boot/grub/grub.cfg
echo "root:awesome" | chpasswd

EOF
umount -R /mnt
echo "create user yourself and add sudo yourself"
echo "Did it worked?"