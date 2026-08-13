#!/bin/sh
read -r username password <~/iisercreds.txt

captiveportalsite="https://firewall.iiserpune.ac.in:8090"

PRODUCTTYPE=0
USERAGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100 Safari/537.36"

sendloginrequest() {
    curl -k -s -m 3 -A "$USERAGENT" -X POST \
        --url "$captiveportalsite/login.xml" \
        --data-urlencode "mode=191" \
        --data-urlencode "username=$username" \
        --data-urlencode "password=$password" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}
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
loginfailedexit() {
    termux-notification -t "IISER Captive Portal" -c "Could not log into IISER captive portal"
    exit
}

sendlogoutrequest >/dev/null 2>&1
output="$(sendloginrequest)" || notconnectedexit
printf '%s' "$output" | grep -qvFm1 "Login failed" || loginfailedexit
termux-job-scheduler --script ~/iiserlogin-job.sh --job-id 11621 --period-ms 7200000 --persisted true
