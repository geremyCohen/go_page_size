#!/bin/bash

# Detect page size and configure GRUB accordingly
PAGESIZE=$(getconf PAGESIZE)

if [ "$PAGESIZE" -eq 65536 ]; then
    echo "Detected 64K page size. Switching to generic kernel..."
    echo "GRUB_FLAVOUR_ORDER=generic" | sudo tee /etc/default/grub.d/local-order.cfg
    sudo update-grub
    sudo reboot
elif [ "$PAGESIZE" -eq 4096 ]; then
    echo "Detected 4K page size. Switching to generic-64k kernel..."
    echo "GRUB_FLAVOUR_ORDER=generic-64k" | sudo tee /etc/default/grub.d/local-order.cfg
    sudo update-grub
    sudo reboot
else
    echo "Unknown page size: $PAGESIZE bytes"
    echo "Expected 4096 (4K) or 65536 (64K)"
    exit 1
fi