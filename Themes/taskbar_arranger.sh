#!/bin/bash
#
# taskbar.sh
# Pins and orders the GNOME dock/taskbar icons to:
#   Files, Chromium, Brave, Shotwell, LibreOffice Writer, Ubuntu/App Store, Settings
#
# This writes org.gnome.shell.app-favorites favorite-apps, which is what
# both the stock GNOME dash and the ubuntu-dock / dash-to-dock extension
# (enabled in mac_theme.sh) read their pinned icons from.
#
# The script auto-detects the correct .desktop filename for each app
# (apt vs snap installs use different names), skips anything not
# installed, and warns you about what it skipped.
#
# Usage:
#   chmod +x taskbar.sh
#   ./taskbar.sh

set -uo pipefail

SEARCH_DIRS=(
    "$HOME/.local/share/applications"
    "/usr/share/applications"
    "/var/lib/snapd/desktop/applications"
)

should_skip_entry() {
    # Returns 0 (skip) if this .desktop file shouldn't be shown in the
    # current session — either explicitly hidden, or excluded/not-included
    # via NotShowIn/OnlyShowIn (per the XDG desktop entry spec). This is
    # what filters out stub files like a Snap Store entry marked
    # NotShowIn=ubuntu, in favor of the session-appropriate one.
    local path="$1"

    if grep -qiE '^(NoDisplay|Hidden)[[:space:]]*=[[:space:]]*true' "$path"; then
        return 0
    fi

    local current="${XDG_CURRENT_DESKTOP:-}"
    [ -z "$current" ] && return 1  # can't evaluate, don't skip

    local not_show_in only_show_in d e
    not_show_in="$(grep -m1 '^NotShowIn=' "$path" | cut -d= -f2)"
    if [ -n "$not_show_in" ]; then
        IFS=':' read -ra sess <<< "$current"
        IFS=';' read -ra excl <<< "$not_show_in"
        for d in "${sess[@]}"; do
            for e in "${excl[@]}"; do
                [ "${d,,}" = "${e,,}" ] && return 0
            done
        done
    fi

    only_show_in="$(grep -m1 '^OnlyShowIn=' "$path" | cut -d= -f2)"
    if [ -n "$only_show_in" ]; then
        IFS=':' read -ra sess <<< "$current"
        IFS=';' read -ra allow <<< "$only_show_in"
        for d in "${sess[@]}"; do
            for e in "${allow[@]}"; do
                [ "${d,,}" = "${e,,}" ] && return 1
            done
        done
        return 0  # OnlyShowIn present but none matched -> skip
    fi

    return 1
}

find_desktop_file() {
    # $1 = space-separated list of candidate desktop file basenames, priority order
    local candidates="$1"
    for candidate in $candidates; do
        for dir in "${SEARCH_DIRS[@]}"; do
            local path="$dir/$candidate"
            if [ -f "$path" ] && ! should_skip_entry "$path"; then
                echo "$candidate"
                return 0
            fi
        done
    done
    return 1
}

ORDERED_FAVORITES=()
MISSING_APPS=()

add_app() {
    # $1 = human-readable name, $2 = space-separated candidate desktop file basenames
    local label="$1"
    local candidates="$2"
    local found
    if found="$(find_desktop_file "$candidates")"; then
        echo "  Found $label -> $found"
        ORDERED_FAVORITES+=("$found")
    else
        echo "  Warning: could not find a .desktop file for $label (tried: $candidates)"
        MISSING_APPS+=("$label")
    fi
}

echo "=== Locating installed applications ==="
add_app "Files"              "org.gnome.Nautilus.desktop nautilus.desktop"
add_app "Chromium"           "chromium_chromium.desktop chromium-browser.desktop chromium.desktop"
add_app "Brave"               "brave-browser.desktop brave_brave.desktop"
add_app "Shotwell"           "shotwell.desktop"
add_app "LibreOffice Writer" "libreoffice-writer.desktop libreoffice-startcenter.desktop"
add_app "Ubuntu/App Store"   "org.gnome.Software.desktop snap-store_snap-store.desktop snap-store_ubuntu-software.desktop ubuntu-software.desktop"
add_app "Settings"           "gnome-control-center.desktop org.gnome.Settings.desktop unity-control-center.desktop"

if [ "${#ORDERED_FAVORITES[@]}" -eq 0 ]; then
    echo ""
    echo "Error: none of the requested apps were found installed. Nothing to set."
    exit 1
fi

echo ""
echo "=== Setting dock order ==="
GVARIANT="[$(printf "'%s', " "${ORDERED_FAVORITES[@]}")"
GVARIANT="${GVARIANT%, }]"

echo "  New favorite-apps: $GVARIANT"
gsettings set org.gnome.shell favorite-apps "$GVARIANT"

echo ""
if [ "${#MISSING_APPS[@]}" -gt 0 ]; then
    echo "Done, but these apps were skipped because no .desktop file was found:"
    for app in "${MISSING_APPS[@]}"; do
        echo "  - $app"
    done
    echo "Check the exact filename with: ls /usr/share/applications | grep -i <name>"
    echo "(or /var/lib/snapd/desktop/applications for snap installs), then rerun this"
    echo "script after adding the right candidate to the matching add_app line above."
else
    echo "Done. Dock order set to: ${ORDERED_FAVORITES[*]}"
fi

echo ""
echo "Note: this only pins/reorders icons — it doesn't install anything."
echo "If ubuntu-dock/dash-to-dock has 'isolate favorites' or per-monitor favorites"
echo "enabled, check its own preferences too: gnome-extensions prefs ubuntu-dock@ubuntu.com"