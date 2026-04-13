#!/bin/sh

echo "Loading infhosted Drivers"

dmesg -c > /dev/null

modprobe -r infhosted infutil cfg80211 compat 2> /dev/null

modprobe compat
modprobe cfg80211
modprobe infutil
modprobe infhosted

sleep 2
dmesg -c
