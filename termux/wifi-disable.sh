#!/bin/sh
termux-wifi-connectioninfo | grep -qF '"ssid": "Students",' && ~/.shortcuts/tasks/iiserlogout.sh
termux-wifi-enable false
termux-job-scheduler --cancel --job-id 11621
