### List available networks
```
nmcli device wifi list
```

### Connect to a new network:
```
nmcli device wifi connect "SSID_NAME" password "your_password"
```

### Switch to a network you've connected to before (saved profile):
```
nmcli connection up "SSID_NAME"
```

### List saved connections:
```
nmcli connection show
```

### Check current connection status:
```
nmcli device status
```

### Disconnect from current wifi:
```
nmcli device disconnect wlan0
```


### List configured VPN connections:
```
nmcli connection show | grep vpn
```

### Connect to a VPN:
```
nmcli connection up "VPN_CONNECTION_NAME"
```

### Disconnect:
```
nmcli connection down "VPN_CONNECTION_NAME"
```

### Vpn installation options (havent tried these commands):
```
sudo apt install network-manager-openvpn
nmcli connection import type openvpn file /path/to/config.ovpn
```

#### WireGuard

```
sudo apt install wireguard
sudo wg-quick up /path/to/wg0.conf
sudo wg-quick down wg0s
```