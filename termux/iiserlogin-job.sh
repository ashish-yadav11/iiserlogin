#!/bin/sh
termux-wifi-connectioninfo | grep -qF '"ssid": "Students",' || exit

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

sendlogoutrequest && sendloginrequest >/dev/null 2>&1
