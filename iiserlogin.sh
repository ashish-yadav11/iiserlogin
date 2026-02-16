#!/bin/dash
notify="notify-send -h string:x-canonical-private-synchronous:iiserlogin"

username="iiser.login"
password="wxyz1234"

PRODUCTTYPE=0
USERAGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100 Safari/537.36"

COOKIEJAR="$(mktemp --tmpdir iiserlogin.XXXXXX)"
cleanup() {
    rm -f "$COOKIEJAR"
    exit
}
trap cleanup HUP INT TERM

sendloginrequest() {
    curl -s -m 3 -c "$COOKIEJAR" -b "$COOKIEJAR" -A "$USERAGENT" -X POST \
        --url "https://firewall.iiserpune.ac.in:8090/login.xml" \
        --data-urlencode "mode=191" \
        --data-urlencode "username=$username" \
        --data-urlencode "password=$password" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}

sendliverequest() {
    lu=$(printf '%s' "$username" | tr '[:upper:]' '[:lower:]')
    curl -s -m 3 -c "$COOKIEJAR" -b "$COOKIEJAR" -A "$USERAGENT" -G \
        --url "https://firewall.iiserpune.ac.in:8090/live" \
        --data-urlencode "mode=192" \
        --data-urlencode "username=$lu" \
        --data-urlencode "a=$(date +%s)000" \
        --data-urlencode "producttype=$PRODUCTTYPE"
}

notconnected() {
    $notify -h int:transient:1 -t 2000 "Not connected to IISER network"
    cleanup
}

loginsuccess() {
    $notify -h int:transient:1 -t 2000 "Successfully logged into IISER captive portal"
}

loginfailed() {
    $notify -t 4000 -u critical "Could not log into IISER captive portal"
    cleanup
}

output="$(sendloginrequest)" || notconnected
if printf '%s' "$output" | grep -qvF "Login failed" ; then
    loginsuccess
else
    loginfailed
fi

while true ; do
    output="$(sendliverequest)" || break
    printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[live_off]]></ack>" && break
    printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[ack]]></ack>" && continue
    output="$(sendloginrequest)" || break
    printf '%s' "$output" | grep -qvF "Login failed" || loginfailed
    sleep 180
done
cleanup
