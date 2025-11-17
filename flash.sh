#!/bin/bash

backup_dir=""
persistent_dir=""

show_help() {
    echo "firmware flasher"
    echo "--backup DIR         (optional) backup persistent partitions"
    echo "--persistent DIR     directory containing persistent partition images (can be same as --backup)"
    echo "--help               this message"
    exit 0
}

if [[ $# -eq 0 ]]; then
    show_help
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --backup)
            backup_dir="$2"
            shift 2
            ;;
        --persistent)
            persistent_dir="$2"
            shift 2
            ;;
        --help)
            show_help
            ;;
        *)
            show_help
            ;;
    esac
done

# Check mandatory argument
if [[ -z "$persistent_dir" ]]; then
    echo "--persistent is required"
    exit 1
fi

echo "Flashing new bootloader"
fastboot erase boot
fastboot flash aboot out/aboot.mbn
fastboot reboot

if [[ -n "$backup_dir" ]]; then
  echo "Backing up partitions"
  mkdir bkp
  for PART in fsc fsg modem modemst1 modemst2 persist sec; do
    fastboot oem dump $PART && fastboot get_staged bkp/$PART.bin
  done
  fastboot erase boot
  fastboot reboot bootloader
  sleep 5
else
  echo "Skipping backup"
fi

echo "Flashing custom partitions"
fastboot flash partition out/gpt_both0.bin
fastboot flash aboot out/aboot.mbn
fastboot flash hyp out/hyp.mbn
fastboot flash rpm out/rpm.mbn
fastboot flash sbl1 out/sbl1.mbn
fastboot flash tz out/tz.mbn
fastboot flash boot out/boot.bin
fastboot -S 200M flash rootfs out/rootfs.bin

echo "Restoring original partitions"
for n in fsc fsg modem modemst1 modemst2 persist sec; do
    fastboot flash ${n} ${persistent_dir}/${n}.bin
done

fastboot reboot
echo "Done"
