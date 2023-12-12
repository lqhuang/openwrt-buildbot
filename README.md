lqhuang's OpenWrt Buildbot

## Target

- upstream: openwrt
- generic: x86_64

no wifi

## Key Features

a web interface is usually listening at http://openwrt.lan/ by default.

## Installed Packages

```html
alsa-utils autocore automount base-files block-mount busybox ca-bundle
default-settings-chn dnsmasq-full dropbear fdisk firewall4 fstools
grub2-bios-setup ipv6helper kmod-8139cp kmod-8139too kmod-ac97 kmod-amazon-ena
kmod-amd-xgbe kmod-bnx2 kmod-button-hotplug kmod-e1000 kmod-e1000e
kmod-forcedeth kmod-fs-f2fs kmod-fs-vfat kmod-i40e kmod-igb kmod-igbvf kmod-igc
kmod-ixgbe kmod-ixgbevf kmod-nf-nathelper kmod-nf-nathelper-extra
kmod-nft-offload kmod-pcnet32 kmod-r8101 kmod-r8125 kmod-r8168
kmod-sound-hda-codec-hdmi kmod-sound-hda-codec-realtek kmod-sound-hda-codec-via
kmod-sound-hda-core kmod-sound-hda-intel kmod-sound-i8x0 kmod-sound-via82xx
kmod-tg3 kmod-tulip kmod-usb-audio kmod-usb-hid kmod-usb-net kmod-usb-net-asix
kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152-vendor
kmod-vmxnet3 libc libgcc libustream-openssl logd luci luci-app-opkg luci-compat
luci-lib-base luci-lib-fs luci-lib-ipkg mkf2fs mtd netifd nftables opkg
partx-utils ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uci uclient-fetch
urandom-seed urngd
```

## Notes for compiling

## Apply diff config

Tune the configuration to official upstream is relying the basis of a config
file `<buildroot>/.config` by running `make defconfig`. These changes will be
expanded into a full config.

## Check diff from upstream (openwrt)

The firmware make process automatically creates the configuration diff file
`config.buildinfo` after 18.06.

## Inspired from

- []()

## References

- [openwrt/openwrt](https://github.com/openwrt/openwrt): This repository is a
  mirror of https://git.openwrt.org/openwrt/openwrt.git It is for reference only
  and is not active for check-ins. We will continue to accept Pull Requests
  here. They will be merged via staging trees then into openwrt.git.

- https://bingmeme.github.io/OpenWrt_CN/
- https://github.com/coolsnowwolf/lede
- [SuLingGG/OpenWrt-Rpi](https://github.com/SuLingGG/OpenWrt-Rpi): Raspberry Pi
  & NanoPi R2S/R4S & G-Dock & x86 OpenWrt Compile Project. (Based on Github
  Action / Daily Update)
- [freifunk-berlin/ansible](https://github.com/freifunk-berlin/ansible): ansible
  config management for Freifunk Berlin infrastructure. Holds buildbot,
  IP-Addr-management and others
