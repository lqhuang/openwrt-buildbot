# Filesystem and Flash Layout

- [Filesystems](https://openwrt.org/docs/techref/filesystems)
  - [OpenWrt File System Hierarchy / Memory Usage](https://openwrt.org/docs/techref/file_system)
  - [Flash memory](https://openwrt.org/docs/techref/flash)
  - [The OpenWrt Flash Layout](https://openwrt.org/docs/techref/flash.layout)
- [Expanding root partition and filesystem](https://openwrt.org/docs/guide-user/advanced/expand_root)
- [OpenWrt on x86 hardware - Expanding root partition and filesystem](https://openwrt.org/docs/guide-user/installation/openwrt_x86#expanding_root_partition_and_filesystem)
- [Fstab Configuration](https://openwrt.org/docs/guide-user/storage/fstab)
- [Filesystems and Partitions](https://openwrt.org/docs/guide-user/storage/filesystems-and-partitions)
- [Extroot configuration](https://openwrt.org/docs/guide-user/additional-software/extroot_configuration)
  - (2024-03-17) Currently block creates some restrictions on what extroot can
    be. It must a filesystem of type: `ext2/3/4`, `f2fs`, `btrfs`, `ntfs`, or
    `ubifs` (note that it can not be a FAT16/32 filesystem).
  - Transferring data: Transfer the content of the current overlay to the
    external drive.
  - Configuring `rootfs_data`/`ubifs`: Configure a mount entry for the the
    original overlay. This will allow you to access the `rootfs_data`/`ubifs`
    partition and customize the extroot configuration.
- [Saving firmware space and RAM](https://openwrt.org/docs/guide-user/additional-software/saving_space)

Major config files

- `/etc/config/fstab`
- `/etc/mtab`

## Persist `/var` to all left space of boot disk

In OpenWrt, `/tmp` resides on a tmpfs-partition and `/var` is a symlink to it by
default.

While using large storage as boot disk (nvme) for x86_64 arch, `/var` could be
formated and persistent to be extra storage.

- `CONFIG_TARGET_ROOTFS_PERSIST_VAR=n`

Basically, it could be formatted at the first boot time.

- [Extroot configuration - Partitioning and formatting](https://openwrt.org/docs/guide-user/additional-software/extroot_configuration#partitioning_and_formatting)
- [Preinit and Root Mount and Firstboot Scripts](https://openwrt.org/docs/techref/preinit_mount)
- [Custom automount script for XFS](https://openwrt.org/docs/guide-user/base-system/hotplug#custom_automount_script_for_xfs)
- [Mounting Block Devices](https://openwrt.org/docs/techref/block_mount)

## Utils (sgdisk, mkfs)

- [An `sgdisk` Walkthrough](https://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html)
- [A `cgdisk` Walkthrough](https://www.rodsbooks.com/gdisk/cgdisk-walkthrough.html)

## Loop device

> In Unix-like operating systems, a loop device, vnd (vnode disk), or lofi (loop
> file interface) is a pseudo-device that makes a computer file accessible as a
> block device.
>
> -- wikipedia

```
losetup -a
losetup -f
```
