# Filesystem and Flash Layout

- [Expanding root partition and filesystem](https://openwrt.org/docs/guide-user/advanced/expand_root)
- [Fstab Configuration](https://openwrt.org/docs/guide-user/storage/fstab)
- [Filesystems](https://openwrt.org/docs/guide-user/storage/filesystems-and-partitions)

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
