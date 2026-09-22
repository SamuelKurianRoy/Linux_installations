#!/bin/bash

SCRIPT="detect_device.sh"
SSH_CONFIG="$HOME/.ssh/config"

# Ensure local script exists before executing
if [ ! -f "$SCRIPT" ]; then
    echo "Error: Local script '$SCRIPT' not found in current directory!"
    exit 1
fi

# Ensure SSH config exists
if [ ! -f "$SSH_CONFIG" ]; then
    echo "Error: SSH config file '$SSH_CONFIG' not found!"
    exit 1
fi

# Dynamically parse hostnames starting with mtx, trois, or user from ~/.ssh/config
mapfile -t HOSTS < <(awk '/^[[:space:]]*Host[[:space:]]+/ {
    for (i=2; i<=NF; i++) {
        if ($i ~ /^(mtx|trois|user)/) {
            print $i
        }
    }
}' "$SSH_CONFIG")

# Verify at least one host was found
if [ ${#HOSTS[@]} -eq 0 ]; then
    echo "No matching hosts (mtx, trois, user) found in $SSH_CONFIG."
    exit 1
fi

echo "Found ${#HOSTS[@]} matching host(s) in $SSH_CONFIG"
echo "Starting device detection scan..."
echo ""

for host in "${HOSTS[@]}"; do
    echo "----------------------------------------"
    echo "Host: $host"
    echo "----------------------------------------"
    
    # -o ConnectTimeout=5 prevents hanging indefinitely on unreachable hosts
    # -o BatchMode=yes prevents interactive password prompts from blocking the loop
    ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" 'bash -s' < "$SCRIPT" 2>/dev/null || echo "[Offline or Connection Failed]"
    
    echo ""
done

echo "Scan complete."
