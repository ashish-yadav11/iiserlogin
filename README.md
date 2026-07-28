# iiserlogin.sh

Shell script to log in to IISER Captive Portal.

# Configuration

Set username and password variables in the script, i.e., replace `iiser.login`
with your actual username and `wxyz1234` with your actual password. See
[`iiserlogin.sh`](https://github.com/ashish-yadav11/dotfiles/blob/master/scripts/iiserlogin.sh)
for my setup using [pass](https://wiki.archlinux.org/title/Pass).

# Usage

```
iiserlogin.sh [oneshot|daemon|logout]
```
Without any argument, the script attempts to log in to the Portal. It also
attempts to send live requests every three minutes if the server supports it,
otherwise it exits. The argument `oneshot` makes the script just log in and
exit. The argument `daemon` changes the behaviour of the script if the server
does not support live requests. The script keeps running and re-logins every
two hours until logging in fails (It logs you out first, after ensuring network
activity is idle, then instantly logs you in. This resets the automatic log out
time. Presumably just logging in repeatedly doesn't reset the automatic log out
time). The argument `logout` logs you out of the portal. One might want to
invoke the script through a
[systemd service](https://wiki.archlinux.org/title/Systemd#Writing_unit_files).
(The IISER Captive Portal doesn't support live requests at the moment, so the
`oneshot` argument is redundant.)

# Cute Trick

You can setup
[NetworkManager dispatcher](https://wiki.archlinux.org/title/NetworkManager#Network_services_with_NetworkManager_dispatcher)
to automatically launch the script after connecting to IISER network (see the
section below).

# My Setup

## Systemd service

[`/etc/systemd/system/iiserlogin.service`](https://github.com/ashish-yadav11/dotfiles/blob/master/config/root-systemd/system/iiserlogin.service)

```
[Unit]
Description=IISER Captive Portal Login

[Service]
User=ashish
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
ExecStart=/home/ashish/.scripts/iiserlogin.sh daemon

```
([`/home/ashish/.scripts/iiserlogin.sh`](https://github.com/ashish-yadav11/dotfiles/blob/master/scripts/iiserlogin.sh))

## NetworkManager dispatcher script

[`/etc/NetworkManager/dispatcher.d/01-iiserlogin.sh`](https://github.com/ashish-yadav11/dotfiles/blob/master/config/root-NetworkManager/dispatcher.d/01-iiserlogin.sh)

```
#!/bin/sh
interface="$1"
status="$2"

case "$status" in

up)
    case "$interface" in
        eno1)
            case "$IP4_DOMAINS" in *"iiserpune.ac.in"*)
                systemctl --no-block restart iiserlogin.service
                exit
                ;;
            esac
            ;;
        wlp5s0)
            case "$CONNECTION_ID" in "Students"|"Guest")
                systemctl --no-block restart iiserlogin.service
                exit
                ;;
            esac
            ;;
    esac
    nmcli -t device show | grep -qFm1 "iiserpune.ac.in" ||
        systemctl --no-block stop iiserlogin.service
    ;;

down)
    nmcli -t device show | grep -qFm1 "iiserpune.ac.in" ||
        systemctl --no-block stop iiserlogin.service
    ;;

esac

```
(`eno1` and `wlps5s0` are the interface names of my ethernet and wifi devices
[run `nmcli`].)
