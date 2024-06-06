# lqhuang's OpenWrt Buildbot

## Target

- upstream: openwrt
- generic: x86_64

no wifi

## Key Features

a web interface is usually listening at http://openwrt.local/ by default.

## Notes for usage

In the current git directory, clone the OpenWrt repository:

```sh
# done by makefile script
make setup-openwrt-src
# what actually did
# git clone --depth 1 --single-branch ${OPENWRT_REPO} ./${BUILDROOT}
```

then, run script to check generated configuration for openwrt:

```sh
make configure [profile=PROFILE]
```

where `PROFILE` is the name of the profile to build. The default profile is `x86_64-default`.
And the profile name is the name of the directory in the `profiles` directory.

Finally, run the build script to output artifacts:

```sh
make all [profile=PROFILE]
```

## Apply diff config

Tune the configuration to official upstream is relying the basis of a config
file `<buildroot>/.config` by running `make defconfig`. These changes will be
expanded into a full config.

## Check diff from upstream (openwrt)

The firmware make process automatically creates the configuration diff file
`config.buildinfo` after 18.06.

## Inspired from

- [icyleaf/openwrt-autobuilder](https://github.com/icyleaf/openwrt-autobuilder)
- [Zheaoli/Auto-OpenWrt](https://github.com/Zheaoli/Auto-OpenWrt)

## References

- [openwrt/openwrt](https://github.com/openwrt/openwrt): This repository is a
  mirror of https://git.openwrt.org/openwrt/openwrt.git It is for reference only
  and is not active for check-ins. We will continue to accept Pull Requests
  here. They will be merged via staging trees then into openwrt.git.
- [stangri’s OpenWrt Packages Documentation](https://docs.openwrt.melmac.net/)
  - [stangri/source.openwrt.melmac.net](https://github.com/stangri/source.openwrt.melmac.net):
    OpenWrt Packages
  - [stangri/repo.openwrt.melmac.net](https://github.com/stangri/repo.openwrt.melmac.net):
    OpenWrt/LEDE Project Packages Repository
- [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt): An
  opensource OpenWrt variant for mainland China users.
  <https://downloads.immortalwrt.org>
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede): Lean's LEDE source
- [BingMeme/OpenWrt_CN](https://github.com/BingMeme/OpenWrt_CN): OpenWrt 简中
  <https://bingmeme.github.io/OpenWrt_CN/>
- [SuLingGG/OpenWrt-Rpi](https://github.com/SuLingGG/OpenWrt-Rpi): Raspberry Pi
  & NanoPi R2S/R4S & G-Dock & x86 OpenWrt Compile Project. (Based on Github
  Action / Daily Update)
- [kenzok8/openwrt-packages](https://github.com/kenzok8/openwrt-packages):
  openwrt 常用软件包 <https://op.dllkids.xyz>
- [kenzok8/small](https://github.com/kenzok8/small): ssr passwall vssr bypass 依
  赖
- [freifunk-berlin/ansible](https://github.com/freifunk-berlin/ansible): ansible
  config management for Freifunk Berlin infrastructure. Holds buildbot,
  IP-Addr-management and others
