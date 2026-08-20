First create this file
```
vim ~/.lan_listener.sh
```

Then paste this inside it
```
#!/bin/bash
while true; do nc -l -p 9999 | xargs -I {} bash -c 'notify-send "LAN Message" "{}" && paplay /usr/share/sounds/freedesktop/stereo/message.oga'; done
```

Then give it executable permission
```
chmod +x ~/.lan_listener.sh
```

Then make this file
```
mkdir -p ~/.config/autostart
vim ~/.config/autostart/lan_listener.desktop
```

Paste this content inside it
```
[Desktop Entry]
Type=Application
Exec=/bin/bash -c "$HOME/.lan_listener.sh"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=LAN Notifier
```

Then reboot the computer for it to take effect

```
sudo reboot now
```
