# Network Configuration - IPv6

- [IPv6 configuration](https://openwrt.org/docs/guide-user/network/ipv6/configuration)
  - Combine `ip6assign` and `ip6hint` to design IPv6 vlan subnets.
  - Setting the `ip6assign` parameter to a value < 64 will allow the
    DHCPv6-server to hand out all but the first `/64` via DHCPv6-Prefix
    Delegation to downstream routers on the interface.

## Troubleshooting

- If the router can ping6 the internet, but lan machines get "Destination
  unreachable: Unknown code 5" or "Source address failed ingress/egress policy"
  then the `ip6assign` option is missing on your lan interface.
