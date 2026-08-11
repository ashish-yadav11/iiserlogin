#!/bin/sh
connected() {
    output="$(termux-wifi-connectioninfo)"
    printf '%s' "$output" | grep -qF '"ssid": "Students",' &&
        printf '%s' "$output" | grep -qF '"supplicant_state": "COMPLETED"'
}

termux-wifi-enable true
t0="$(date +%s)"
while ! connected ; do
    sleep 1
    [ "$(date +%s)" -gt "$(( t0 + 10 ))" ] && exit
done
~/.shortcuts/tasks/iiserlogin.sh
termux-job-scheduler --script ~/iiserlogin-job.sh --job-id 100 --period-ms 7200000 --persisted true
