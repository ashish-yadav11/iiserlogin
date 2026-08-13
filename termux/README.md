# iiserlogin.sh

Shell script to log in to IISER Captive Portal on Android.

# Configuration

Install `Termux`, `Termux:API` and `Termux-Widget`, say from Fdroid. Give
`Termux:API` the requisite permissions from Settings. Install `curl` and `git`
on `Termux`.
```
pkg install curl git
```
Clone the repository and change directory to termux.
```
git clone https://github.com/ashish-yadav11/iiserlogin
cd iiserlogin/termux
```
Then run
```
./install.sh 'username' 'password'
```
with your credentials (inside the quotes). Run
```
adb shell settings put global captive_portal_mode 0
```
after connecting your phone to your PC with USB Debugging to disable automatic
Captive Portal handling by the Android system. Create Widgets on the home
screen pointing to the various scripts through `Termux-Widget`. Voila!
