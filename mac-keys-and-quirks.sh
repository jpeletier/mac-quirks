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
    exit 1;
fi

# Copy several config files for acpi stuff and keys:
rm -rf /tmp/root
cp -R root/ /tmp/
chown -R root:root /tmp/root
rsync -avh --progress /tmp/root/ /

exit 0

# install service to disable XHC1 wakeup on startup:
sudo systemctl daemon-reload
sudo systemctl start proc-acpi
sudo systemctl enable proc-acpi

# make function keys work without Fn
# https://unix.stackexchange.com/questions/121395/on-an-apple-keyboard-under-linux-how-do-i-make-the-function-keys-work-without-t
echo 2 > /sys/module/hid_apple/parameters/fnmode
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
update-initramfs -u -k all