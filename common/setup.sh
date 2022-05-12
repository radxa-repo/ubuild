#!/bin/bash

postinst() {
    if [[ ! -e /boot/uEnv.txt ]]
    then
        cp "$SCRIPT_DIR/uEnv.txt" /boot
    fi
    
    if [[ ! -e /boot/boot.cmd ]]
    then
        update_bootcmd
    fi

    if [[ ! -e /boot/boot.scr ]]
    then
        mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
    fi
}

update_bootcmd() {
    cp "$SCRIPT_DIR/boot.cmd" /boot
    mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
}

update_bootloader() {
    local DEVICE=$1
    local SOC=${2:-$(dtsoc)}

    case "$SOC" in
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

update_spi() {
    if [[ ! -e /dev/mtdblock0 ]]
    then
        echo "/dev/mtdblock0 is missing." >&2
        exit 1
    fi

    case "$(dtsoc)" in
        rockchip*)
            dd if=/dev/zero of=/dev/mtdblock0 || true
            cp "$SCRIPT_DIR/idbloader-tpl.img" /tmp/spi.img
            dd if="$SCRIPT_DIR/u-boot.itb" of=/tmp/spi.img bs=512 seek=768
            #dd if=/dev/zero of=/tmp/spi.img bs=1 count=0 seek=4M
            dd if=/tmp/spi.img of=/dev/mtdblock0
            rm /tmp/spi.img
            ;;
        *)
            echo Unknown SOC. >&2
            exit 1
            ;;
    esac

}

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

ACTION="$1"
shift
$ACTION "$@"