#!/bin/sh
username="iiser.login"
password="wxyz1234"

captiveportalsite="https://firewall.iiserpune.ac.in:8090"

PRODUCTTYPE=0
USERAGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100 Safari/537.36"

sendlogoutrequest() {
    curl -k -s -m 3 -A "$USERAGENT" -X POST \
        --url "$captiveportalsite/logout.xml" \
        --data-urlencode "mode=193" \
        --data-urlencode "username=$username" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}

notconnectedexit() {
    termux-notification -t "IISER Captive Portal" -c "Not connected to IISER network"
    exit
}

logoutfailed() {
    termux-notification -t "IISER Captive Portal" -c "Could not log out of IISER captive portal"
}

output="$(sendlogoutrequest)" || notconnectedexit
printf '%s' "$output" | grep -qFm1 "You&#39;ve signed out" || logoutfailed
