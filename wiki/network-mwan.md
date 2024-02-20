# Multiple Wan for OpenWRT

## General

Check OpenWRT Docs

- [Using multiple WAN IPs](https://openwrt.org/docs/guide-user/network/wan/multiple_public_ips)
  - Utilize multiple WAN IPs on the same interface.
  - Use a specific WAN IP for a specific LAN host.
- [Using multiple wan with multiple routers](https://openwrt.org/docs/guide-user/network/wan/multiple_wan_multiple_routers)
  - we have two or more router and every router has one wan connection active
    providing one public ip address
  - For now load balancing and other stuff are not required. We want
    availability.
- [Multi-WAN (Internet access through more than one modem/device)](https://openwrt.org/docs/guide-user/network/wan/multiwan/start)

## mwan3

- mwan3
- luci-app-mwan3

The mwan3 package provides the following functionality and capabilities:

- Outbound WAN traffic load balancing or fail-over with multiple WAN interfaces
  based on a numeric weight assignment
- Monitors each WAN connection using repeated tests and can automatically route
  outbound traffic to another WAN interface if the first WAN interface loses
  connectivity
- Creating outbound traffic rules to customize which outbound connections should
  use which WAN interface (policy based routing). This can be customised based
  on source IP, destination IP, source port(s), destination port(s), type of IP
  protocol etc
- Physical and/or logical WAN interfaces are supported
- The firewall mask (default `0x3F00`) which is used to mark outgoing traffic
  can be configured in the `/etc/config/mwan3` globals section. This is useful
  if you also use other packages (nodogsplash) which use the firewall masking
  feature. This value is also used to set how many interfaces are supported.

```
MultiWAN Manager - Interfaces

Mwan3 requires that all interfaces have a unique metric configured in /etc/config/network.
Names must match the interface name found in /etc/config/network.
Names may contain characters A-Z, a-z, 0-9, _ and no spaces-
Interfaces may not share the same name as configured members, policies or rules.
```

Finally I deprecated it while it still depends on `iptables`.

## MWAN with netifd

Implemented by PBR

- [MWAN with netifd](https://openwrt.org/docs/guide-user/network/wan/multiwan/mwan_netifd)
  - Implement multi-WAN based on PBR with netifd.
  - Support dual-stack setups using IPv4 and IPv6.
  - Perform connectivity check with ICMP and ICMPv6.
  - Provide a simple failover method.
- [PBR with netifd](https://openwrt.org/docs/guide-user/network/routing/pbr_netifd)
- [netifd (Network Interface Daemon) – Technical Reference](https://openwrt.org/docs/techref/netifd)
- [Routing example: PBR with iproute2](https://openwrt.org/docs/guide-user/network/routing/examples/pbr_iproute2)
