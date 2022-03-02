#!/bin/bash

# how to find out keys
# `sudo xev` gives out key codes
# `xmodmap -pk` lists current mapping
# `xmodmap -e "keycode=xx = key" `  sets up the mapping.

function withxmodmap() {
    # map F12 key to Delete
    xmodmap -e "keycode 96 = Delete Delete F12"

    # map right cmd to be AltGr
    xmodmap -e "keycode 134 = ISO_Level3_Shift"

    # map right Alt to be Delete too
    xmodmap -e "keycode 108 = Delete"

    # map Fn+F3 to be F12
    xmodmap -e "keycode 128 = F12"

}

if [ "$(id -u)" != "0" ]; then
    echo "Please run as root"
    exit 1
fi

# Copy several config files for acpi stuff and keys:
rm -rf /tmp/root
cp -R root/ /tmp/
chown -R root:root /tmp/root
rsync -avh --progress /tmp/root/ /

# install service to disable XHC1 wakeup on startup:
sudo systemctl daemon-reload
sudo systemctl start proc-acpi
sudo systemctl enable proc-acpi

# make function keys work without Fn
# https://unix.stackexchange.com/questions/121395/on-an-apple-keyboard-under-linux-how-do-i-make-the-function-keys-work-without-t
echo 2 >/sys/module/hid_apple/parameters/fnmode
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
update-initramfs -u -k all

####################
# Wifi tweaks:
# 1.- Purge possible old drivers, add brcmfmac driver:
apt-get purge bcmwl-kernel-source
apt update
update-pciids
apt install firmware-b43-installer
# 2.- driver parameters file is copied to /lib/firmware/brcm/ as part of the
# common step in this script
# Taken from https://github.com/Dunedan/mbp-2016-linux/issues/47#issuecomment-958597026
# Longer thread: https://bugzilla.kernel.org/show_bug.cgi?id=193121
# summary: https://unix.stackexchange.com/questions/573064/wifi-being-very-slow-not-working-for-linux-on-mac-why-wont-it-connect
# NOTE: must change mac address in /lib/firmware/brcm/brcmfmac43602-pcie.txt to your mac address

# 3.- reload driver, although probably a reboot would be better
sudo rmmod brcmfmac && sudo modprobe brcmfmac
