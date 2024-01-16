# Wiki

## Glossary

固件格式

- kernel: 内置最简文件系统的 Linux 内核, 适用于首次安装或故障恢复
- sysupgrade: 从本来就是 openwrt 的固件基础上升级, 或者无刷机引导限制的机器上直
  接刷入此格式文件
- factory: 用于从设备的原厂固件刷入 factory, 再刷入 breed 之类不死使用
- ext4: 可以扩展磁盘空间大小
- squashfs: 可以使用 重置功能（恢复出厂设置）
- efi: efi 引导, 非 BIOS 引导（优先使用 efi 固件, 无法启动时再换无 efi 固件）
- rootfs: 不带引导, 可自行定义用 grub 或者 syslinux 来引导
- combined: 带引导
- .img: 物理机使用
- .vmdk: 虚拟机 ESXi/VMware 使用
- .qcow2: 虚拟机 PVE 使用
- .vdi: 虚拟机 VirtualBox 使用
- .vhdx: 虚拟机 Hyper-V 使用
- .tar: 容器 Docker、LXC 使用
- IPK.zip: 压缩文件是随固件一起提供的 ipk, 包括未集成到固件里的一些例如
  dockerman, 仅适用于同目录下的固件, 其他人编译的固件不保证可用!

- `ext4-combined-efi.img.gz`: This disk image uses a single read-write ext4
  partition without a read-only squashfs root filesystem. As a result, the root
  partition can be expanded to fill a large drive (e.g. SSD/SATA/mSATA/SATA
  DOM/NVMe/etc). Features like Failsafe Mode or Factory Reset will not be
  available as they need a read-only squashfs partition in order to function. It
  has both the boot and root partitions and Master Boot Record (MBR) area with
  updated GRUB2.
- `ext4-combined.img.gz`: This disk image is the same as above but it is
  intended to be booted with PC BIOS instead of EFI.
- `ext4-rootfs.img.gz`: This is a partition image of only the root partition. It
  can be used to install OpenWRT without overwriting the boot partition and
  Master Boot Record (MBR).
- `kernel.bin`
- `squashfs-combined-efi.img.gz`: This disk image uses the traditional OpenWrt
  layout, a squashfs read-only root filesystem and a read-write partition where
  settings and packages you install are stored. Due to how this image is
  assembled, you will have less than 100MB of space to store additional packages
  and configuration, and extroot does not work. It supports booting from EFI.
- `squashfs-combined.img.gz`: This disk image is the same as above but it is
  intended to be booted with PC BIOS instead of EFI.
- `squashfs-rootfs.img.gz`:
- `rootfs.tar.gz`: This contains all the files from the root partition. It can
  be extracted onto a root filesystem without the need of overwriting the
  partition. To avoid conflicts, it is highly recommended you backup any older
  files and extract this file onto an empty filesystem.

## Install OpenWrt

Boot with a Linxu live CD/USB, then

```sh
# Unpack image
gunzip openwrt-*.img.gz

# Identify disk (to replace sdX in the following command below)
lsblk

# Write image
dd if=openwrt-21.02.0-x86-64-generic-ext4-combined.img bs=1M of=/dev/sdX
```

- [OpenWRT Docs: OpenWrt on x86 hardware (PC / VM / server)](https://openwrt.org/docs/guide-user/installation/openwrt_x86)

## Protecting web interface

Rebind to LAN only

```sh
uci set uhttpd.main.listen_http="192.168.1.1:80"
uci commit
/etc/init.d/uhttpd restart
```

## User guides

- Base system
  - [DDNS client configuration](https://openwrt.org/docs/guide-user/base-system/ddns)
  - [System configuration /etc/config/system](https://openwrt.org/docs/guide-user/base-system/system_configuration)
  - [User Configuration /etc/config/users](https://openwrt.org/docs/guide-user/base-system/users)
    - [Create new users and groups for applications or system services](https://openwrt.org/docs/guide-user/additional-software/create-new-users)
    - [Elevating privileges with sudo](https://openwrt.org/docs/guide-user/security/sudo)
  - [Dropbear configuration](https://openwrt.org/docs/guide-user/base-system/dropbear)
    - [Dropbear key-based authentication](https://openwrt.org/docs/guide-user/security/dropbear.public-key.auth)
- [Network](https://openwrt.org/docs/guide-user/network/start)
  - [Network configuration /etc/config/network](https://openwrt.org/docs/guide-user/network/network_configuration)
  - [OpenWrt as router device](https://openwrt.org/docs/guide-user/network/openwrt_as_routerdevice)
  - [OpenWrt as client device](https://openwrt.org/docs/guide-user/network/openwrt_as_clientdevice)
  - [Dnsmasq DHCP server](https://openwrt.org/docs/guide-user/base-system/dhcp.dnsmasq)
  - [PBR (Policy-Based Routing)](https://openwrt.org/docs/guide-user/network/routing/pbr)
    - [docs.openwrt.melmac.net: Policy-Based Routing ](https://docs.openwrt.melmac.net/pbr/)
- [Firewall](https://openwrt.org/docs/guide-user/firewall/start)
- [System configuration not handled by UCI](https://openwrt.org/docs/guide-user/base-system/notuci.config)
- [Secure access to your router](https://openwrt.org/docs/guide-user/security/secure.access)
- [Verifying OpenWrt firmware binary](https://openwrt.org/docs/guide-quick-start/verify_firmware_checksum)

## Developer guides

- [Build system essentials](https://openwrt.org/docs/guide-developer/toolchain/buildsystem_essentials)
- [Build system setup](https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem)
- ❗
  [Build system usage](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
  - [UCI defaults](https://openwrt.org/docs/guide-developer/uci-defaults)
  - [UCI extras](https://openwrt.org/docs/guide-user/advanced/uci_extras)
- [Using the Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder)
- [OpenWrt Buildroot – Technical Reference](https://openwrt.org/docs/techref/buildroot)
- [Embedding Files in Image](https://openwrt.org/docs/guide-developer/embedding-files-in-image)
- [Patching your application: Editing existing files](https://openwrt.org/docs/guide-developer/helloworld/chapter8)
- [Patching your application: Adding new files](https://openwrt.org/docs/guide-developer/helloworld/chapter7)
- Filesystems
  - [Filesystems](https://openwrt.org/docs/techref/filesystems)
  - [OpenWrt File System Hierarchy / Memory Usage](https://openwrt.org/docs/techref/file_system)
  - [Filesystems and Partitions](https://openwrt.org/docs/guide-user/storage/filesystems-and-partitions)
  - [Flash memory](https://openwrt.org/docs/techref/flash)
  - [The OpenWrt Flash Layout](https://openwrt.org/docs/techref/flash.layout)
  - [Saving firmware space and RAM](https://openwrt.org/docs/guide-user/additional-software/saving_space)
  - [Extroot configuration](https://openwrt.org/docs/guide-user/additional-software/extroot_configuration)

## Monitoring

- [User guide / LuCI web interface / luci-app-statistics](https://openwrt.org/docs/guide-user/luci/luci_app_statistics)
- [User guide / Performance and logging / collectd](https://openwrt.org/docs/guide-user/perf_and_log/statistic.collectd)

## Additional enhancements

- [AdGuard Home](https://openwrt.org/docs/guide-user/services/dns/adguard-home)
- [Show available package upgrades after SSH login](https://openwrt.org/docs/guide-user/additional-software/show_upgradable_packages_after_ssh_login)

## CLI based upgrades

- [Upgrading OpenWrt firmware using LuCI and CLI - Command-line instructions](https://openwrt.org/docs/guide-user/installation/generic.sysupgrade#command-line_instructions)
- [Upgrading OpenWrt firmware using CLI](https://openwrt.org/docs/guide-user/installation/sysupgrade.cli)
