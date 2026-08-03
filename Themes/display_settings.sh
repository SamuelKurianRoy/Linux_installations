#!/bin/bash
#
# settings.sh — GNOME power & display settings tweaks
#
#   1. Screen turn-off after inactivity      -> Never
#   2. Automatic suspend after inactivity    -> Disabled
#   3. Show battery percentage               -> Enabled
#   4. Blank screen delay                    -> Never  (same key as #1)
#   5. Lock screen on suspend                -> Disabled
#
# Usage: ./settings.sh
#

set -euo pipefail

if ! command -v gsettings &>/dev/null; then
    echo "Error: gsettings not found. This script requires a GNOME desktop environment." >&2
    exit 1
fi

echo "Applying GNOME power/display settings..."

# --- 1 & 4. Blank screen / screen turn-off after inactivity -> Never ---
# idle-delay (seconds) controls when the screen blanks due to inactivity.
# 0 disables it entirely — this is the single setting behind both #1 and #4.
gsettings set org.gnome.desktop.session idle-delay 0
echo "  [OK] Screen blank / turn-off delay set to Never"

# Belt-and-suspenders: idle-delay above tells gnome-shell not to blank the
# screen, but on X11 sessions (as opposed to Wayland) the X server has its
# own independent DPMS/screensaver timers that can still blank the display
# regardless of the gsettings value. Only relevant under X11.
if [ "${XDG_SESSION_TYPE:-}" = "x11" ] && command -v xset &>/dev/null; then
    xset s off
    xset s noblank
    xset -dpms
    echo "  [OK] X11 DPMS / screensaver blanking disabled directly"
fi

# --- 2. Disable automatic suspend (AC and battery) ---
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
echo "  [OK] Automatic suspend disabled (AC + battery)"

# --- 3. Show battery percentage ---
gsettings set org.gnome.desktop.interface show-battery-percentage true
echo "  [OK] Battery percentage indicator enabled"

# --- 5. Disable lock screen on suspend ---

# Warn if this key is locked down by a system-wide dconf policy
# (e.g. /etc/dconf/db/local.d/locks/*) — in that case gsettings
# will silently succeed but the value won't actually change.
if [ "$(gsettings writable org.gnome.desktop.screensaver lock-enabled)" != "true" ]; then
    echo "  [WARN] org.gnome.desktop.screensaver lock-enabled is locked by a" >&2
    echo "         system dconf policy and cannot be changed per-user." >&2
fi

gsettings set org.gnome.desktop.screensaver lock-enabled false

# Ubuntu ships a patched gnome-screensaver schema with an extra key that
# controls locking specifically on suspend/resume, independent of
# lock-enabled above. Only present on Ubuntu/derivatives — guard for
# stock GNOME / other distros where this key doesn't exist.
if gsettings list-keys org.gnome.desktop.screensaver 2>/dev/null | grep -q '^ubuntu-lock-on-suspend$'; then
    gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
    echo "  [OK] Lock screen on suspend disabled (incl. Ubuntu suspend override)"
else
    echo "  [OK] Lock screen on suspend disabled"
fi

echo "Done. Some changes may require re-login to take full visible effect."
