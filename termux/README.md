# iiserlogin.sh

Shell script to log in to IISER Captive Portal on Android.

# Configuration

Install `Termux`, `Termux:API` and `Termux-Widget`, say from Fdroid. Initialize
mirrors in `Termux`.
```
termux-change-repo
```
Just press `Enter` on `<OK>` two times after running the command, if you don't
know what to do. Install `termux-api`, `curl` and `git` on `Termux`.
```
pkg update && pkg upgrade
pkg install termux-api curl git
```
Press `Y` and `Enter` if you are prompted and don't know what to do.

Clone this repository and change directory to termux.
```
git clone https://github.com/ashish-yadav11/iiserlogin
cd iiserlogin/termux/
```
Then run
```
./install.sh 'username' 'password'
```
with your credentials (inside quotes).

Launch `Termux:API` and give it the permissions it shows on the screen. Now,
you should be able to log in with the command `iiserlogin` and logout with
`iiserlogout`. There is one subtlety though. Android system itself handles the
Captive Portal after initially connecting to the Wi-Fi. It doesn't let other
programs access the Wi-Fi network unless you sign in through the system page,
or select the option `Sign in through Browser` on the page. To disable Android
handling the Captive Portal, run
```
adb shell settings put global captive_portal_mode 0
```
after connecting your phone to your PC with USB Debugging (search the web on
how to setup `adb`). Now after connecting to the Wi-Fi, you can directly log in
by running the command `iiserlogin` on `Termux`. The script attempts to create
a `2 hour` frequency job to automatically relogin, so that you are never logged
out. For `Termux:API` to manage Wi-Fi connections, you need to give it Location
access through Android Settings (Allow all the time). Also make sure it has
Wi-Fi control access in `Apps/Special app access` in Settings.

The `wifi-enable` script enables Wi-Fi, waits for 15 seconds to see if you get
connected to `Students`, and then instantly logs you in. `wifi-disable` logs
you out, cancels the `2 hour` frequency relogin job, and turns Wi-Fi off.

Create Widgets on the home screen pointing to the various scripts through
`Termux-Widget`, and then you can just tap the icons to do the job!
