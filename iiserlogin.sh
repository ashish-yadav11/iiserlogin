#!/bin/sh
notify="notify-send -h string:x-canonical-private-synchronous:iiserlogin"

username="iiser.login"
password="wxyz1234"

sendloginrequest() {
    curl -m 3 -s -X POST -d "mode=191&username=$username&password=$password&a=$(date +%s)000&producttype=1" https://firewall.iiserpune.ac.in:8090/login.xml
}

sendliverequest() {
    curl -m 3 -s "https://firewall.iiserpune.ac.in:8090/live?mode=192&username=$username&a=$(date +%s)000&producttype=1"
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

output="$(sendloginrequest)" || notconnected
if echo "$output" | grep -qvFm1 "Login failed" ; then
    loginsuccess
else
    loginfailed
fi

while true ; do
    output="$(sendliverequest)" || break
    echo "$output" | grep -qFm1 "<ack><![CDATA[live_off]]></ack>" && break
    echo "$output" | grep -qFm1 "<ack><![CDATA[ack]]></ack>" && continue
    output="$(sendloginrequest)" || break
    echo "$output" | grep -qvFm1 "Login failed" || loginfailed
    sleep 180
done
