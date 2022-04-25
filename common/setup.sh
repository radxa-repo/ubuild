#!/bin/bash

postinst() {
    [[ ! -e /boot/uEnv.txt ]] && cp "$SCRIPT_DIR/uEnv.txt" /boot
    [[ ! -e /boot/boot.cmd ]] && cp "$SCRIPT_DIR/boot.cmd" /boot
    [[ ! -e /boot/boot.scr ]] && mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
}

update_bootcmd() {
    cp "$SCRIPT_DIR/boot.cmd" /boot
    mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
}

update_bootloader() {
    local DEVICE=$1

    case "$(dtsoc)" in
        amlogic*)
            dd if="$SCRIPT_DIR/u-boot.bin.sd.bin" of=$DEVICE bs=1 count=444
            dd if="$SCRIPT_DIR/u-boot.bin.sd.bin" of=$DEVICE bs=512 skip=1 seek=1
            ;;
        rockchip*)
            dd if="$SCRIPT_DIR/idbloader.img" of=$DEVICE bs=512 seek=64
            dd if="$SCRIPT_DIR/u-boot.itb" of=$DEVICE bs=512 seek=16384
            ;;
        *)
            echo Unknown SOC. >&2
            exit 1
            ;;
    esac
}

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

$1