#!/usr/bin/env bash

set -e
set -x

rm /mnt/var/cache/xbps/*.xbps{,.sig}

xbps-install -y zerofree

mount -o remount,ro /mnt
zerofree /dev/disk/by-label/void-root
