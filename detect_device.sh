#!/bin/bash
#
# detect_device.sh
#
# Detects CPU architecture and device type (orinnx, orinnano, or pc).
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Detect the device type that corresponds to the current hardware
# ---------------------------------------------------------------------------
detect_device_type() {
    arch=$(uname -m)

    if [ "$arch" = "x86_64" ]; then
        echo "pc"
        return
    fi

    if [ "$arch" = "aarch64" ]; then
        if [ -f "/etc/nv_boot_control.conf" ]; then
            sku=$(grep "^TNSPEC" /etc/nv_boot_control.conf | awk '{print $2}' | cut -d'-' -f3)
            case "$sku" in
                0000|0001) echo "orinnx" ;;
                0003|0004|0005) echo "orinnano" ;;
                *) echo "unknown_jetson_sku_$sku" ;;
            esac
        else
            echo "unknown_arm"
        fi
    else
        echo "unknown_arch_$arch"
    fi
}

ARCH=$(uname -m)
DEVICE_TYPE=$(detect_device_type)

MODE="info"
if [ $# -gt 0 ]; then
    case "$1" in
        --type|--vpu|--folder) MODE="type" ;;
        --arch)                MODE="arch" ;;
        -h|--help)
            echo "Usage: $0 [--type|--arch|-h]"
            echo ""
            echo "  (no flag)   Print Architecture and Type"
            echo "  --type      Print only the device type (orinnx/orinnano/pc)"
            echo "  --arch      Print only the CPU architecture (x86_64/aarch64)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--type|--arch|-h]" >&2
            exit 1
            ;;
    esac
fi

case "$MODE" in
    type)
        echo "$DEVICE_TYPE"
        ;;
    arch)
        echo "$ARCH"
        ;;
    info)
        echo "Architecture   : $ARCH"
        echo "Type           : $DEVICE_TYPE"
        ;;
esac
