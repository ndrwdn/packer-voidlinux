#!/usr/bin/env bash

set -ex

xbps-install -Sy gptfdisk

sgdisk --zap-all /dev/sda
dd if=/dev/zero of=/dev/sda bs=512 count=2048
wipefs --all /dev/sda

sgdisk --new=1:0:+1007K --attributes=1:set:2 --typecode=1:ef02 --change-name=1:"MBR Spacer Boot Partition" /dev/sda
sgdisk --new=2:0:0 --typecode=2:8e00 --change-name=2:"Void Linux LVM Partition" /dev/sda

pvcreate /dev/sda2
vgcreate VoidVolGroup /dev/sda2

lvcreate -L 512M VoidVolGroup -n VoidSwap
lvcreate -l +100%FREE VoidVolGroup -n VoidRoot

mkfs.ext4 -L void-root /dev/mapper/VoidVolGroup-VoidRoot
mkswap -L void-swap /dev/mapper/VoidVolGroup-VoidSwap
sleep 1s # wait for udev to pick them up
mount /dev/disk/by-label/void-root /mnt
swapon /dev/disk/by-label/void-swap

mkdir /mnt/{dev,proc,sys}
mount --rbind /dev /mnt/dev
mount --rbind /proc /mnt/proc
mount --rbind /sys /mnt/sys

echo Y | xbps-install -SR http://repo.voidlinux.eu/current -yr /mnt \
  base-system \
  lvm2 \
  grub \
  lsof \
  htop \
  curl \
  vim \
  emacs \
  git \
  git-perl \
  tree \
  ripgrep \
  zsh \
  tmux \
  salt \
  virtualbox-ose-guest

cp -a /etc/resolv.conf /mnt/etc/resolv.conf
