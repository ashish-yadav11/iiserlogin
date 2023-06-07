# iiserlogin.sh

Shell script to login to IISER Captive Portal.

# Configuration

Set username and password variables in the script, i.e., replace `iiser.login`
with your actual username and `wxyz1234` with your actual password. Then, just
execute the script. You can also bind the script to some keybinding.

# Technical Point (no one needs to worry about)

Though currently the IISER Captive Portal doesn't require to send live status,
it can in principle do so. In that case, the program will keep on running in
the background. For that, it is ideal to run the script through a systemd
service and just restart the service when it is required to relogin.

# Cute Trick

You can setup NetworkManager dispatcher to automatically launch the script when
you connect to IISER network (see the section below).

# My Setup

## Systemd service

```
[Unit]
Description=IISER Captive Portal Login
 
[Service]
User=ashish
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
ExecStart=/home/ashish/.scripts/iiserlogin.sh

```

## NetworkManager dispatcher script

```
#!/bin/sh
interface="$1"
status="$2"

[ "$status" != up ] && exit
case "$interface" in
    eno1)
        nmcli -t device show eno1 |
         grep -qFm1 "IP4.DOMAIN[1]:iiserpune.ac.in" &&
            systemctl restart iiserlogin.service
        ;;
    wlp5s0)
        [ "$CONNECTION_ID" = Students ] && nmcli -t device show wlp5s0 |
         grep -qFm1 "IP4.DOMAIN[1]:iiserpune.ac.in" &&
            systemctl restart iiserlogin.service
        ;;
esac

```
