#!/bin/bash
#
# mac_theme.sh
# Based on: https://github.com/SamuelKurianRoy/Linux_installations/blob/main/Mac_theme.md
#
# Covers Parts 1-5 + the Fonts portion of Part 6.
# Deliberately STOPS before "Terminal Font Fix" and everything after it
# (Window Control Buttons, Wallpaper, Hostname Change, Auto-hide Taskbar).
#
# Usage:
#   chmod +x mac_theme.sh
#   ./mac_theme.sh

set -uo pipefail

BUILD_DIR="$HOME/mac-theme-build"
mkdir -p "$BUILD_DIR"

clone_or_update() {
    # $1 = repo URL, $2 = target dir name
    local repo_url="$1"
    local dir_name="$2"
    if [ -d "$BUILD_DIR/$dir_name" ]; then
        echo "  $dir_name already cloned, pulling latest..."
        (cd "$BUILD_DIR/$dir_name" && git pull) || echo "  Warning: git pull failed for $dir_name, continuing with existing copy."
    else
        git clone "$repo_url" "$BUILD_DIR/$dir_name" || { echo "  Error: failed to clone $dir_name"; return 1; }
    fi
}

echo "=== Part 1: WhiteSur GTK Theme ==="
sudo apt install -y libxml2-utils
clone_or_update "https://github.com/vinceliuice/WhiteSur-gtk-theme.git" "WhiteSur-gtk-theme"
(cd "$BUILD_DIR/WhiteSur-gtk-theme" && ./install.sh) || echo "  Warning: GTK theme install.sh reported an issue."
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"

echo ""
echo "=== Part 2: WhiteSur Icon Theme ==="
clone_or_update "https://github.com/vinceliuice/WhiteSur-icon-theme.git" "WhiteSur-icon-theme"
(cd "$BUILD_DIR/WhiteSur-icon-theme" && ./install.sh) || echo "  Warning: icon theme install.sh reported an issue."
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur"

echo ""
echo "=== Part 3: WhiteSur Cursor Theme ==="
clone_or_update "https://github.com/vinceliuice/WhiteSur-cursors.git" "WhiteSur-cursors"
(cd "$BUILD_DIR/WhiteSur-cursors" && sudo ./install.sh) || echo "  Warning: cursor theme install.sh reported an issue."
gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"

echo ""
echo "=== Part 4: GNOME Shell Theme (Top Bar) ==="
if ! gnome-extensions list 2>/dev/null | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
    echo "  user-theme extension not found, attempting install via apt..."
    echo "  (it ships bundled inside the 'gnome-shell-extensions' package, not as a standalone package)"
    sudo apt update
    sudo apt install -y gnome-shell-extensions \
        || echo "  Warning: apt install failed. You may need the extensions.gnome.org installer script instead."
fi
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com \
    || echo "  Warning: could not enable user-theme extension, skipping shell theme."
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Light" 2>/dev/null \
    || echo "  Warning: user-theme schema not available yet (extension may need a shell restart first)."

echo ""
echo "=== Part 5: Dash to Dock (macOS-style Dock via ubuntu-dock) ==="
gnome-extensions disable dash-to-dock@micxgx.gmail.com 2>/dev/null \
    || echo "  Note: dash-to-dock not installed/already disabled, skipping."
gnome-extensions enable ubuntu-dock@ubuntu.com \
    || echo "  Warning: ubuntu-dock extension not found."
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode DYNAMIC
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.4

echo ""
echo "=== Part 6 (Fonts only, stopping before Terminal Font Fix) ==="
sudo apt install -y fonts-cantarell
gsettings set org.gnome.desktop.interface font-name "Cantarell 11"
gsettings set org.gnome.desktop.interface document-font-name "Cantarell 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Cantarell Bold 11"

echo ""
echo "=== Part 10: Auto-hide the Dock ==="
# dock-fixed must be false for autohide to actually take visual effect —
# this is the key the Settings > Appearance > Dock "Auto-hide the Dock"
# toggle flips. autohide was already set true in Part 5, but without
# dock-fixed=false the dock stays pinned and never hides.
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true

echo ""
echo "=== Part 11: Blur my Shell (transparent/blended top panel) ==="
# WhiteSur's default panel is a low-opacity white tint, not a true blend.
# Blur my Shell adds real backdrop blur to the top panel so it blends with
# whatever's behind it, like macOS vibrancy.
if ! gnome-extensions list 2>/dev/null | grep -q "blur-my-shell@aunetx"; then
    sudo apt update
    if ! sudo apt install -y gnome-shell-extension-blur-my-shell 2>/dev/null; then
        echo "  Not available via apt on this Ubuntu release. Falling back to"
        echo "  the extensions.gnome.org installer script (extension ID 3193)..."
        if [ ! -f "$BUILD_DIR/gnome-shell-extension-installer" ]; then
            wget -O "$BUILD_DIR/gnome-shell-extension-installer" \
                https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer
            chmod +x "$BUILD_DIR/gnome-shell-extension-installer"
        fi
        "$BUILD_DIR/gnome-shell-extension-installer" 3193 --yes \
            || echo "  Warning: installer script failed too. Try installing manually from extensions.gnome.org."
    fi
fi
gnome-extensions enable blur-my-shell@aunetx \
    || echo "  Warning: could not enable blur-my-shell (needs a shell restart first if just installed — rerun this script after restarting the shell)."
echo "  Installed and enabled (if the extension existed after install)."
echo "  One manual step remains (no confirmed stable gsettings keys to"
echo "  script safely): open its preferences —"
echo "    gnome-extensions prefs blur-my-shell@aunetx"
echo "  — go to the Panel tab, turn blur ON, and set its background style"
echo "  to 'Transparent'. Adjust the blur strength slider to taste."


echo ""
echo "=== Part 12: Wallpaper ==="
WALLPAPER_URL="https://github.com/SamuelKurianRoy/Linux_installations/blob/main/Themes/macos-big-sur-wallpaper-1-scaled.jpg?raw=true"
WALLPAPER_PATH="$BUILD_DIR/macos-big-sur-wallpaper-1-scaled.jpg"
if wget -O "$WALLPAPER_PATH" "$WALLPAPER_URL"; then
    ABS_WALLPAPER_PATH="$(realpath "$WALLPAPER_PATH")"
    gsettings set org.gnome.desktop.background picture-uri "file://$ABS_WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$ABS_WALLPAPER_PATH" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-options "zoom"
    echo "  Wallpaper downloaded to $ABS_WALLPAPER_PATH and set."
else
    echo "  Error: failed to download wallpaper from $WALLPAPER_URL"
fi

echo ""
echo "Done through Part 6 (Fonts) plus Auto-hide Dock (Part 10), Blur my"
echo "Shell (Part 11), and Wallpaper (Part 12)."
echo "Terminal Font Fix, Window Control Buttons, and Hostname Change were"
echo "intentionally skipped."
echo ""
echo "Restart GNOME Shell to see the shell/top-bar theme take effect:"
echo "  Alt+F2 -> r -> Enter (X11), or log out/in (Wayland)."
