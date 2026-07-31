#!/usr/bin/env bash
#
# setup_shortcuts.sh
# ------------------------------------------------------------------
# Sets up custom GNOME keyboard shortcuts on Ubuntu:
#   Ctrl+Alt+V        -> Open VS Code
#   Super+E           -> Open Files (Nautilus)
#   Super+PrintScreen -> Take a screenshot
#
# Also sets these GNOME Terminal app shortcuts:
#   Ctrl+V            -> Paste
#   Ctrl+Shift+A      -> Select All
#
# Also installs two bash helpers into ~/.bashrc:
#   remote()   - open a remote SSH path directly in VS Code
#                (from https://github.com/SamuelKurianRoy/Linux_installations/blob/main/shortcuts.md)
#   explorer() - Windows-style `explorer .` / `explorer <path>` that
#                opens a folder in the Files (Nautilus) app
# ------------------------------------------------------------------

set -euo pipefail

echo "==> Checking prerequisites..."

if ! command -v gsettings >/dev/null 2>&1; then
    echo "gsettings not found. This script is intended for GNOME on Ubuntu."
    exit 1
fi

if ! command -v code >/dev/null 2>&1; then
    echo "WARNING: 'code' command not found in PATH. The VS Code shortcut will"
    echo "         still be registered, but won't work until the VS Code CLI"
    echo "         is installed (Shell Command: Install 'code' command in PATH)."
fi

if ! command -v gnome-screenshot >/dev/null 2>&1; then
    echo "==> Installing gnome-screenshot..."
    sudo apt update
    sudo apt install -y gnome-screenshot
fi

SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
KEY_PATH_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# --- Shortcuts to add -----------------------------------------------------
NAMES=("Open VS Code" "Open Files" "Take Screenshot")
COMMANDS=("code" "nautilus" "gnome-screenshot")
BINDINGS=("<Primary><Alt>v" "<Super>e" "<Super>Print")

echo "==> Reading existing custom keybindings..."
CURRENT=$(gsettings get "$SCHEMA" custom-keybindings)

# Parse existing custom keybinding paths so we don't clobber any you already have.
# Keep the quotes intact on each element so it can be rejoined into a valid
# gsettings array literal later (e.g. "'/org/.../custom0/'").
EXISTING_PATHS=()
if [[ "$CURRENT" != "@as []" && "$CURRENT" != "[]" ]]; then
    INNER="${CURRENT#\[}"
    INNER="${INNER%\]}"
    IFS=',' read -ra RAW_PARTS <<< "$INNER"
    for part in "${RAW_PARTS[@]}"; do
        trimmed="$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [[ -n "$trimmed" ]] && EXISTING_PATHS+=("$trimmed")
    done
fi

# Plain (unquoted) versions, just for checking which customN slots are taken
EXISTING_PLAIN=()
for p in "${EXISTING_PATHS[@]}"; do
    EXISTING_PLAIN+=("$(echo "$p" | tr -d "'\"")")
done

# Find the first free customN slot so existing bindings are untouched
START_INDEX=0
while true; do
    CANDIDATE="${KEY_PATH_BASE}/custom${START_INDEX}/"
    TAKEN=0
    for p in "${EXISTING_PLAIN[@]}"; do
        [[ "$p" == "$CANDIDATE" ]] && TAKEN=1 && break
    done
    [[ $TAKEN -eq 0 ]] && break
    START_INDEX=$((START_INDEX + 1))
done

NEW_PATHS=()
for i in "${!NAMES[@]}"; do
    idx=$((START_INDEX + i))
    KEY_PATH="${KEY_PATH_BASE}/custom${idx}/"

    echo "==> Setting '${NAMES[$i]}' -> ${BINDINGS[$i]}"

    gsettings set "${SCHEMA}.custom-keybinding:${KEY_PATH}" name "${NAMES[$i]}"
    gsettings set "${SCHEMA}.custom-keybinding:${KEY_PATH}" command "${COMMANDS[$i]}"
    gsettings set "${SCHEMA}.custom-keybinding:${KEY_PATH}" binding "${BINDINGS[$i]}"

    NEW_PATHS+=("'${KEY_PATH}'")
done

if [[ ${#EXISTING_PATHS[@]} -gt 0 ]]; then
    ALL_PATHS=("${EXISTING_PATHS[@]}" "${NEW_PATHS[@]}")
else
    ALL_PATHS=("${NEW_PATHS[@]}")
fi
JOINED=$(IFS=,; echo "${ALL_PATHS[*]}")
gsettings set "$SCHEMA" custom-keybindings "[$JOINED]"

echo "==> Keyboard shortcuts configured:"
echo "    Ctrl+Alt+V         -> VS Code"
echo "    Super+E            -> Files (Nautilus)"
echo "    Super+PrintScreen  -> Screenshot"

# ------------------------------------------------------------------
# Terminal app shortcuts: Ctrl+V (paste) and Ctrl+Shift+A (select all)
# These live in the terminal emulator's own keybinding schema, not the
# desktop-wide media-keys schema used above.
# ------------------------------------------------------------------
echo "==> Configuring terminal shortcuts..."

if command -v gnome-terminal >/dev/null 2>&1; then
    TERM_SCHEMA="org.gnome.Terminal.Legacy.Keybindings"
    TERM_PATH="/org/gnome/terminal/legacy/keybindings/"

    gsettings set "${TERM_SCHEMA}:${TERM_PATH}" paste "'<Primary>v'"
    gsettings set "${TERM_SCHEMA}:${TERM_PATH}" select-all "'<Primary><Shift>a'"

    echo "    Ctrl+V         -> Paste"
    echo "    Ctrl+Shift+A   -> Select All"
    echo "    (Note: Ctrl+V no longer reaches the shell's 'literal insert' function"
    echo "     in GNOME Terminal, since Paste now intercepts it first.)"
else
    echo "    gnome-terminal not found — skipping terminal shortcut setup."
    echo "    If you use a different terminal app (Tilix, Terminator, Kitty, etc.),"
    echo "    set Paste/Select All from that app's own Preferences/Keybindings."
fi

# ------------------------------------------------------------------
# Add the remote() helper to ~/.bashrc (idempotent)
# ------------------------------------------------------------------
BASHRC="$HOME/.bashrc"
MARKER="# >>> vscode remote helper >>>"

if grep -qF "$MARKER" "$BASHRC" 2>/dev/null; then
    echo "==> remote() helper already present in ~/.bashrc, skipping."
else
    echo "==> Adding remote() helper to ~/.bashrc..."
    cat >> "$BASHRC" <<'EOF'

# >>> vscode remote helper >>>
# Opens a remote SSH path directly in VS Code, e.g.:
#   remote mtx003@192.168.1.1:/home/mtx003/img
remote() {
    local host="${1%%:*}"
    local path="${1#*:}"
    code --folder-uri "vscode-remote://ssh-remote+${host}${path}"
}
# <<< vscode remote helper <<<
EOF
fi

# ------------------------------------------------------------------
# Add the explorer() helper to ~/.bashrc (idempotent)
# Windows-style: `explorer .` or `explorer <path>` opens that folder
# in the Files (Nautilus) app.
# ------------------------------------------------------------------
EXPLORER_MARKER="# >>> explorer helper >>>"

if grep -qF "$EXPLORER_MARKER" "$BASHRC" 2>/dev/null; then
    echo "==> explorer() helper already present in ~/.bashrc, skipping."
else
    echo "==> Adding explorer() helper to ~/.bashrc..."
    cat >> "$BASHRC" <<'EOF'

# >>> explorer helper >>>
# Opens a folder in the Files (Nautilus) app, Windows-style:
#   explorer .          # current directory
#   explorer /some/path # a specific path
explorer() {
    local target="${1:-.}"

    if [[ ! -e "$target" ]]; then
        echo "explorer: '$target' does not exist" >&2
        return 1
    fi

    local abs_path
    abs_path="$(realpath "$target")"

    nohup nautilus "$abs_path" >/dev/null 2>&1 &
    disown
}
# <<< explorer helper <<<
EOF
fi

echo
echo "All done. Run 'source ~/.bashrc' (or open a new terminal) to use remote() and explorer()."
echo "Shortcuts should be active immediately — no logout needed."
