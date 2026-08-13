#!/bin/sh
if termux-wifi-connectioninfo | grep -qF '"ssid": "Students",' ; then
    ~/.shortcuts/tasks/iiserlogout
else
    termux-job-scheduler --cancel --job-id 11621
fi
termux-wifi-enable false
