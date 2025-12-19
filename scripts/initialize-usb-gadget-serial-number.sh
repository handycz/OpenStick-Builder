#!/bin/bash
# Initializes usb gadget serial number

SERIAL=$(cat /sys/class/net/wlan0/address | sha256sum | cut -b-16)
sed -i "s/#serial-number-placeholder#/$SERIAL/g" /etc/gt/templates/serial-and-ethernet.scheme
