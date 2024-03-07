# Troubleshooting

## Problem:

Execute `make world V=sc` to build the whole system, but failed.

```sh
make world V=sc
```

Error msg:

```plain
....
checking whether mkfifo rejects trailing slashes... yes
checking whether mkfifoat rejects trailing slashes... yes
checking whether mknod can create fifo without root privileges... configure: error: in `<buildroot>/build_dir/host/tar-1.34':
configure: error: you should not run configure as root (set FORCE_UNSAFE_CONFIGURE=1 in environment to bypass this check)
See `config.log' for more details
make[3]: *** [Makefile:36: <buildroot>/build_dir/host/tar-1.34/.configured] Error 1
make[3]: Leaving directory '<buildroot>/tools/tar'
time: tools/tar/compile#9.41#3.23#15.94
    ERROR: tools/tar failed to build.
make[2]: *** [tools/Makefile:226: tools/tar/compile] Error 1
make[2]: Leaving directory '<buildroot>'
...
```

Solution

1. there is no need to build as root. (Why I saw once docs saying that we should
   build as root?)
   > Do everything as an unprivileged user, not root, without sudo. --
   > [Build system usage](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
2. If build as root, set env by `export FORCE_UNSAFE_CONFIGURE=1` before
   `make world V=sc`

## Legacy iptables rules detected

No more `iptables` please

```
Legacy rules detected

There are legacy iptables rules present on the system. Mixing iptables and nftables rules is discouraged and may lead to incomplete traffic filtering.
```

Part of legacy apps still cann't utilize `iptables-nft` well.

After check my installed feeds, the following apps will add `iptables` as deps
forcelly:

- qos-scripts & sqm-scripts
  - luci-app-sqm
- mwan3
  - luci-app-mwan3
- pbr-iptables
  - optional alternative: pbr (with `nftables`)
- nodogsplash
  - luci-app-splash
- wifidog
- wifidog-tls

Refs:

- [Warning iptables use legacy](https://forum.openwrt.org/t/warning-iptables-use-legacy/127752)

## DHCP doesn't delegate correct DNS Server to clients

1. Set WAN dns

```
config interface 'wan'
	option proto 'pppoe'
	...
	option peerdns '0'
	option dns '208.67.222.222 208.67.220.220'
```

2. Set DHCP Option 6 for interface `lan`
   - for example: "6,192.168.1.1,192.168.1.2"

```
config dhcp 'lan'
	option interface 'lan'
	...
	list dhcp_option '6,208.67.222.222,208.67.220.220'
```

3. DHCP and DNS -> DHCP-Options

```
config dhcp 'lan'
	option interface 'lan'
	option leasetime '2h'
	list ra_flags 'managed-config'
	list ra_flags 'other-config'
	list domain 'local'
  ...
	list dhcp_option '6,192.168.1.1'
```

- [Correct Way to Set DNS Server](https://forum.openwrt.org/t/correct-way-to-set-dns-server/34019)
