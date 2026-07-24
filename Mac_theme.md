# Ubuntu → macOS Look & Feel — Setup Summary

## System Info
- **OS:** Ubuntu 20.04 (Focal Fossa)
- **Desktop:** GNOME Shell 3.36.9
- **User:** `user@yaswanth` (hostname later changed)
- **Session Type:** X11

---

## What We Did & Why

### 1. WhiteSur GTK Theme
**Why:** To make windows, menus, and UI elements look like macOS.
```bash
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh
```
- Installed dependency `libxml2-utils` automatically during install.
- Applied via:
```bash
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
```

---

### 2. WhiteSur Icon Theme
**Why:** To replace default Ubuntu icons with macOS-style icons.
```bash
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
./install.sh
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur"
```

---

### 3. WhiteSur Cursor Theme
**Why:** To replace the default cursor with a macOS-style one.
```bash
git clone https://github.com/vinceliuice/WhiteSur-cursors.git
cd WhiteSur-cursors
sudo ./install.sh
gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
```

---

### 4. GNOME Shell Theme (Top Bar)
**Why:** To style the top bar to match macOS.
- Enabled the `user-theme` extension first:
```bash
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Light"
```

---

### 5. Dash to Dock (macOS-style Dock)
**Why:** To get a centered bottom dock like macOS.

#### What went wrong:
- `gnome-shell-extension-dash-to-dock` was **not available via apt** on Ubuntu 20.04.
- `gnome-shell-extension-manager` was also **not available via apt**.
- Tried to build Dash to Dock from source — failed because `msgfmt` was missing.
  - Fixed with: `sudo apt install gettext -y`
- Built and installed successfully, but extension showed **ERROR state** because **Dash to Dock v105 is incompatible with GNOME Shell 3.36.9**.

#### Final Solution:
Used **`ubuntu-dock`** (Ubuntu's built-in Dash to Dock fork) which was already installed.
```bash
gnome-extensions disable dash-to-dock@micxgx.gmail.com  # disabled broken one
gnome-extensions enable ubuntu-dock@ubuntu.com

# Move dock to bottom and style it
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.7
```

---

### 6. Fonts
**Why:** To match macOS typography style.
```bash
sudo apt install fonts-cantarell -y
gsettings set org.gnome.desktop.interface font-name "Cantarell 11"
gsettings set org.gnome.desktop.interface document-font-name "Cantarell 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Cantarell Bold 11"
```

#### Terminal Font Fix:
The monospace font was changed which broke the terminal look. Reset it:
```bash
gsettings reset org.gnome.desktop.interface monospace-font-name
# Or set explicitly:
gsettings set org.gnome.desktop.interface monospace-font-name "Ubuntu Mono 13"
```

---

### 7. Window Control Buttons
**Why:** To position the close/minimize/maximize buttons like macOS (left side) and then moved back to right on user request.

```bash
# Move to LEFT (macOS style) — done initially
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:"

# Move back to RIGHT — user's final preference
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
```

---

### 8. macOS Wallpaper
**Why:** To complete the macOS aesthetic.
```bash
cd ~
wget -O mac-wallpaper.jpg "https://512pixels.net/downloads/macos-wallpapers/11-0.jpg"
gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/mac-wallpaper.jpg"
```

---

### 9. Hostname Change
**Why:** User wanted to change `yaswanth` in `user@yaswanth:~$` in the terminal prompt. That name is the system hostname.
```bash
sudo hostnamectl set-hostname newname
```
Takes effect immediately after reopening the terminal. No reboot needed.

---

## Current State
- ✅ WhiteSur GTK theme applied (Light)
- ✅ WhiteSur icons applied
- ✅ WhiteSur cursors applied
- ✅ macOS-style dock at bottom (using ubuntu-dock)
- ✅ Window buttons on the right
- ✅ Cantarell fonts applied (terminal font reset to Ubuntu Mono)
- ✅ macOS wallpaper set
- ✅ Hostname changed

## Pending / Optional
- [ ] macOS-style top bar with clock, battery, wifi tweaks
- [ ] App theming (Firefox, VS Code etc.) to match macOS style
