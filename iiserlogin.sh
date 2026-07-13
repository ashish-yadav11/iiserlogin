#!/bin/sh
notify="notify-send -h string:x-canonical-private-synchronous:iiserlogin"

username="iiser.login"
password="wxyz1234"

captiveportalsite="https://firewall.iiserpune.ac.in:8090"
liveinterval=180
daemoninterval=7200
pingsite1="www.cloudflare.com"
pingsite2="www.google.com"

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
sendliverequest() {
    lu=$(printf '%s' "$username" | tr '[:upper:]' '[:lower:]')
    curl -k -s -m 3 -A "$USERAGENT" -G \
        --url "$captiveportalsite/live" \
        --data-urlencode "mode=192" \
        --data-urlencode "username=$lu" \
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

notconnected() {
    $notify -h int:transient:1 -t 2000 "Not connected to IISER network"
    exit
}
loginsuccess() {
    $notify -h int:transient:1 -t 2000 "Successfully logged into IISER captive portal"
}
loginfailed() {
    $notify -t 4000 -u critical "Could not log into IISER captive portal"
    exit
}
logoutsuccess() {
    $notify -h int:transient:1 -t 2000 "Successfully logged out of IISER captive portal"
}
logoutfailed() {
    $notify -t 4000 -u critical "Could not log out of IISER captive portal"
}

if [ "$1" = "logout" ] ; then
    output="$(sendlogoutrequest)" || notconnected
    if printf '%s' "$output" | grep -qFm1 "You&#39;ve signed out" ; then
        logoutsuccess
    else
        logoutfailed
    fi
    exit
fi

# log out first to hopefully reset automatic logout time
[ "$1" = "daemon" ] && sendlogoutrequest >/dev/null 2>&1
output="$(sendloginrequest)" || notconnected
if printf '%s' "$output" | grep -qvFm1 "Login failed" ; then
    loginsuccess
else
    loginfailed
fi
[ "$1" = "oneshot" ] && exit

while true ; do
    output="$(sendliverequest)" || break
    if printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[live_off]]></ack>" ; then
        [ "$1" != "daemon" ] && exit
        iface="$(ip route show default)"
        iface="${iface#*dev }"
        iface="${iface%% proto*}"
        while true ; do
            sleep "$daemoninterval"
            lo=0
            while true ; do
                # check if we have been logged out
                ping -q -c1 -W1 "$pingsite1" >/dev/null 2>&1 ||
                    ping -q -c1 -W1 "$pingsite2" >/dev/null 2>&1 || break
                # wait for network inactivity (logging out is intrusive)
                IFS='' read -r rx1 <"/sys/class/net/$iface/statistics/rx_bytes"
                IFS='' read -r tx1 <"/sys/class/net/$iface/statistics/tx_bytes"
                sleep 3
                IFS='' read -r rx2 <"/sys/class/net/$iface/statistics/rx_bytes"
                IFS='' read -r tx2 <"/sys/class/net/$iface/statistics/tx_bytes"
                sleep 1
                IFS='' read -r rx3 <"/sys/class/net/$iface/statistics/rx_bytes"
                IFS='' read -r tx3 <"/sys/class/net/$iface/statistics/tx_bytes"
                [ "$(( rx3 - rx1 + tx3 - tx1 ))" -le 2048 ] &&
                    [ "$(( rx3 - rx2 + tx3 - tx2 ))" -le 512 ] && { lo=1; break ;}
            done
            [ "$lo" = 1 ] && sendlogoutrequest >/dev/null 2>&1
            output="$(sendloginrequest)" || exit
            printf '%s' "$output" | grep -qvFm1 "Login failed" || exit
        done
    fi
    if printf '%s' "$output" | grep -qFm1 "<ack><![CDATA[ack]]></ack>" ; then
        sleep "$liveinterval"
        continue
    fi
    output="$(sendloginrequest)" || break
    printf '%s' "$output" | grep -qvFm1 "Login failed" || loginfailed
done
