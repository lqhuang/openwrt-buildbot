# Routing and Policy Based Routing

Policy Based Routing (PBR) is a general term for routing techniques that allow
you to make routing decisions based on policies.

PBR could be implemented in multiple levels and multiple ways, such as using
`iproute2` (`ip route`), `netifd`, `nftable` with `fw4` or combination of them
and other app level packages (eg: `pbr`/ `mwan3` / `sing-box` in OpenWRT).

## Resources

### iproute2

- [Routing basics](https://openwrt.org/docs/guide-user/network/routing/basics)
  - Note that by default OpenWrt announces IPv6 default route only for GUA and
    applies source filter for IPv6 that allows routing only for prefixes
    delegated from the upstream router.
  - Default routing tables
  - Default routing rules
  - debug routing
    ```sh
    ip address show; ip route show table all
    ip rule show; ip -6 rule show; nft list ruleset
    ```
- [Static routes](https://openwrt.org/docs/guide-user/network/routing/routes_configuration)
- [Routing rules](https://openwrt.org/docs/guide-user/network/routing/ip_rules)
- [Routing example: IPv4](https://openwrt.org/docs/guide-user/network/routing/examples/routing_in_ipv4)
- [Routing example: IPv6](https://openwrt.org/docs/guide-user/network/routing/examples/routing_with_ipv6)
- [Routing example: PBR with iproute2](https://openwrt.org/docs/guide-user/network/routing/examples/pbr_iproute2)

### netifd

PBR with `netifd` helps to utilize different routing tables to route traffic to
a specific interface based on traffic parameters like ingress/egress interface,
source/destination address, firewall mark, etc.

- [PBR with netifd](https://openwrt.org/docs/guide-user/network/routing/pbr_netifd)
- [netifd (Network Interface Daemon) – Technical Reference](https://openwrt.org/docs/techref/netifd)

### nftables

- [nftables](https://openwrt.org/docs/guide-user/firewall/misc/nftables)
- [Firewall configuration `/etc/config/firewall`](https://openwrt.org/docs/guide-user/firewall/firewall_configuration)
- [IP set examples](https://openwrt.org/docs/guide-user/firewall/fw3_configurations/fw3_config_ipset)

### PBR app

pbr & luci-app-pbr

- [PBR app](https://openwrt.org/docs/guide-user/network/routing/pbr_app)
- [docs.openwrt.melmac.net: Policy-Based Routing](https://docs.openwrt.melmac.net/pbr/)
