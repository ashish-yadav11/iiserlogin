# iiserlogin.sh

Shell script to log in to IISER Captive Portal.

# Configuration

Set username and password variables in the script, i.e., replace `iiser.login`
with your actual username and `wxyz1234` with your actual password. Then just
execute the script. You can also bind the script to some keybinding.

# Technical Point (no one needs to worry about)

Though currently the IISER Captive Portal doesn't require to send live status,
it can in principle do so. In that case, the program will keep on running in
the background. Hence it is ideal to run the script through a
[systemd service](https://wiki.archlinux.org/title/Systemd#Writing_unit_files)
and just restart the service whenever logging in is required.

# Cute Trick

You can setup
[NetworkManager dispatcher](https://wiki.archlinux.org/title/NetworkManager#Network_services_with_NetworkManager_dispatcher)
to automatically launch the script after connecting to IISER network (see the
section below).

# My Setup

## Systemd service

`/etc/systemd/system/iiserlogin.service`


```
[Unit]
Description=IISER Captive Portal Login
 
[Service]
User=ashish
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
ExecStart=/home/ashish/.scripts/iiserlogin.sh

```
([`/home/ashish/.scripts/iiserlogin.sh`](https://github.com/ashish-yadav11/dotfiles/blob/master/scripts/iiserlogin.sh))

## NetworkManager dispatcher script

`/etc/NetworkManager/dispatcher.d/01-iiserlogin.sh`


```
#!/bin/sh
interface="$1"
status="$2"

[ "$status" != up ] && exit
case "$interface" in
    eno1)
        nmcli -t device show eno1 |
         grep -qFm1 "GENERAL.CONNECTION:IISER Wired Connection" &&
            systemctl --no-block restart iiserlogin.service
        ;;
    wlp5s0)
        { [ "$CONNECTION_ID" = Students ] || [ "$CONNECTION_ID" = Guest ] ;} &&
            systemctl --no-block restart iiserlogin.service
        ;;
esac

```
(`eno1` and `wlps5s0` are the interface names of my ethernet and wifi devices
[run `nmcli`].)
