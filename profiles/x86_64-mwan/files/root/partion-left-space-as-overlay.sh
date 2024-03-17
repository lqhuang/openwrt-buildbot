#!/bin/bash

# Check root permission
if [[ $(id -u) -ne 0 ]]; then
   echo "Please run script as root"
   exit 1
fi

# inspired by https://openwrt.org/docs/guide-user/advanced/expand_root
ROOT_BLK="$(readlink -f /sys/dev/block/"$(awk -e '$9=="/dev/root"{print $3}' /proc/self/mountinfo)")"
ROOT_DISK="/dev/$(basename "${ROOT_BLK%/*}")"; echo "ROOT_DISK=${ROOT_DISK}"

ROOT_PART_NUM="${ROOT_BLK##*[^0-9]}"; echo "ROOT_PART_NUM=${ROOT_PART_NUM}"
ROOT_DEV="/dev/${ROOT_BLK##*/}"; echo "ROOT_DEV=${ROOT_DEV}"
LOOP_DEV="$(awk -e '$5=="/overlay"{print $9}' /proc/self/mountinfo)"
LOOP_DEV="$(block info | sed -n -e '/MOUNT="\S*\/overlay"/s/:\s.*$//p')"

# Note: First of all fix the GPT table
# ```
# Warning: Not all of the space available to /dev/nvme0n1 appears to be used, you can fix the GPT to use all of the space (an extra 495399055 blocks) or continue with the current setting?
# Fix/Ignore? Fix
# ```
parted -f -s "$ROOT_DISK"

# Create new partitions for /home and /var

sgdisk -p "$ROOT_DISK"
# # Find the first available sector
# FIRST_AVAIL_SECTOR="$(sgdisk -F ${ROOT_DISK})"

DATA_PART_NUM="$((${ROOT_PART_NUM}+1))"; echo "DATA_PART_NUM=${DATA_PART_NUM}"
DATA_SIZE="+192G"
sgdisk -n "${DATA_PART_NUM}:0:${DATA_SIZE}" -t "${DATA_PART_NUM}:8300" "${ROOT_DISK}"

sgdisk -p "$ROOT_DISK"

# Inform system and kernel with the new partition table
partprobe $ROOT_DISK
partx $ROOT_DISK

# Format new partitions as concrete filesystem

DATA_DEV="$(echo ${ROOT_DEV} | sed "s/p[0-9]*$/p${DATA_PART_NUM}/")"; echo "DATA_DEV=${DATA_DEV}"

mkfs.f2fs -f -l rootfs_data -O extra_attr,inode_checksum,sb_checksum "${DATA_DEV}"

## Generate block info
block detect
# Import to fstab (Optional by yourself)
# block detect | uci import fstab


# !!! IMPORTANT NOTES !!!
# You should make overlayfs to expand to fit the new partition size
# And Free space for / should be the same as /overlay.
# You can use `resize2fs` to expand overlay filesystem.
