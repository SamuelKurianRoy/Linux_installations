```
nano ~/.lan_listener.sh
```

```
#!/bin/bash
while true; do nc -l -p 9999 | xargs -I {} bash -c 'notify-send "LAN Message" "{}" && paplay /usr/share/sounds/freedesktop/stereo/message.oga'; done
```

```
chmod +x ~/.lan_listener.sh
```

```
mkdir -p ~/.config/autostart
nano ~/.config/autostart/lan_listener.desktop
```

```
[Desktop Entry]
Type=Application
Exec=/bin/bash -c "$HOME/.lan_listener.sh"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=LAN Notifier
```

