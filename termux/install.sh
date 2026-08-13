#!/bin/sh
if [ -n "$1" ] && [ -n "$2" ] ; then
    printf '%s %s' "$1" "$2" >~/iisercreds.txt
else
    cp iisercreds.txt ~/iisercreds.txt
fi
cp iiserlogin-job.sh ~/iiserlogin-job.sh
mkdir -p ~/.shortcuts/tasks/
cp iiserlogin.sh ~/.shortcuts/tasks/iiserlogin
cp iiserlogout.sh ~/.shortcuts/tasks/iiserlogout
cp wifi-enable.sh ~/.shortcuts/tasks/wifi-enable
cp wifi-disable.sh ~/.shortcuts/tasks/wifi-disable
