**Install brave**

```
sudo apt update
```
```
sudo apt install curl
```
```
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
```
```
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
```
```
sudo apt update
```
```
sudo apt install brave-browser
```







**Install vscode**

```
sudo apt update
```
```
sudo apt install wget gpg
```
```
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
```
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
```
```
sudo apt update
```
```
sudo apt install code
```






**Install git and gh**

```
sudo apt update
```
```
sudo apt install git
```
```
sudo apt install gh
```

```
git config --global user.name "$(gh api user -q '.name // .login')"
```
```
git config --global user.email "$(gh api user -q 'if .email then .email else "\(.id)+\(.login)@users.noreply.github.com" end')"
```

**Install vim**

```
sudo apt  update
```

```
sudo apt install vim
```

**Install ifconfig**
```
sudo apt install net-tools
```


**Install Docker**

```
sudo apt update
```
```
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
if it fails run these commands

```
sudo apt update
```
```
sudo apt install -y ca-certificates curl gnupg
```
```
sudo install -m 0755 -d /etc/apt/keyrings
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
```
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```
sudo apt update
```
```
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```





**Install Anydesk**

```
sudo apt update
```
```
sudo apt install -y ca-certificates curl gnupg
```
```
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
```
```
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list
```
```
sudo apt update
```
```
sudo apt install anydesk
```


**Enable ssh access**

```
sudo apt update
```
```
sudo apt install openssh-server
```
```
sudo systemctl enable ssh
```
```
sudo systemctl start ssh
```
```
sudo systemctl status ssh   # confirm it's "active (running)"
```

```
sudo nano /etc/ssh/sshd_config
```

Look for 
```
#Port 22
```
change it

then:

```
sudo systemctl restart ssh
```

once passkey is set

change it to no
```
PasswordAuthentication no
```

after changes 

```
sudo systemctl restart ssh
```


Also change the lock screen settings

then change the closing lid settings by using the following commands
```
sudo nano /etc/systemd/logind.conf
```
Find these lines and set the corresponding values
```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```
```
sudo systemctl restart systemd-logind
```
To Change to mac theme go to 
https://github.com/SamuelKurianRoy/Linux_installations/blob/main/Mac_theme.md

do the things mentioned
