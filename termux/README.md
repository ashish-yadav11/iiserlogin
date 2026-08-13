# iiserlogin.sh

Shell script to log in to IISER Captive Portal on Android.

# Configuration

Install `Termux`, `Termux:API`, `Termux-Widget`, say from Fdroid. Install
`curl` and `git` on Termux by:
```
pkg install curl git
```
Clone the repository and change directory to termux:
```
git clone https://github.com/ashish-yadav11/iiserlogin
cd iiserlogin/termux
```
Then run
```
./install.sh username password
```
with your credentials.
Run
```
adb shell settings put global captive_portal_mode 0
```
after connecting your phone to your pc with USB Debugging to disable automatic
Captive Portal handling by the Android system. Give Termux:API the requisite
permissions from settings. Create Widgets on the home screen pointing to the
various scripts. Voila!
