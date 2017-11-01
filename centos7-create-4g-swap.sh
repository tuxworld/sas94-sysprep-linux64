#!/bin/bash
free -g
cat /proc/swaps
swapon -s
fallocate -l 4G /swapfile
ls -lh /swapfile
dd if=/dev/zero of=/swapfile count=4096 bs=1MiB
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
free -g
cat /proc/swaps