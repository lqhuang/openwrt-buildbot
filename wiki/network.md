# Basic Network Configuration

## Devices and Interfaces

- [Router vs switch vs gateway and NAT](https://openwrt.org/docs/guide-user/network/switch_router_gateway_and_nat)
- [OpenWrt as router device](https://openwrt.org/docs/guide-user/network/openwrt_as_routerdevice)
- [Linux network interfaces](https://openwrt.org/docs/guide-developer/networking/network.interfaces)
- [Network configuration /etc/config/network](https://openwrt.org/docs/guide-user/network/network_configuration)
- WAN
  - [Accessing the modem through the router](https://openwrt.org/docs/guide-user/network/wan/access.modem.through.nat)
  - [WAN interface protocols](https://openwrt.org/docs/guide-user/network/wan/wan_interface_protocols)
  - [WAN / Bridge mode](https://openwrt.org/docs/guide-user/network/wan/bridge-mode)
- [IPv4 configuration](https://openwrt.org/docs/guide-user/network/ipv4/configuration)
- [IPv6 configuration](https://openwrt.org/docs/guide-user/network/ipv6/configuration)
- [Network interface aliases](https://openwrt.org/docs/guide-user/network/network_interface_alias)
  - Alias sections can be used to define further IPv4 and IPv6 addresses for
    interfaces. They also allow combinations like DHCP on the main interface and
    a static IPv6 address in the alias, for example to deploy IPv6 on wan while
    keeping normal internet connectivity. Each interface can have multiple
    aliases attached to it.
  - TL;DR: aliases feature help to support both `DHCP` and `Static`

## DHCP

DHCPv4

- Stateless and stateful DHCPv4 server mode.

DHCPv6 support with 2 modes of operation:

1. DHCPv6 Server mode: stateless, stateful and Prefix Delegation (PD) server
   mode:
   - Stateless and stateful address assignment.
   - Prefix delegation support.
   - Dynamic reconfiguration of any changes in Prefix Delegation.
   - Hostname detection and hosts-file creation.
2. DHCPv6 Relay mode: A mostly standards-compliant DHCPv6-relay:
   - Supports rewriting of the announced DNS server addresses.

- [DHCP and DNS configuration /etc/config/dhcp](https://openwrt.org/docs/guide-user/base-system/dhcp)
- [DHCP and DNS examples](https://openwrt.org/docs/guide-user/base-system/dhcp_configuration)
- [Dnsmasq DHCP server](https://openwrt.org/docs/guide-user/base-system/dhcp.dnsmasq)
- [odhcpd](https://openwrt.org/docs/techref/odhcpd)
