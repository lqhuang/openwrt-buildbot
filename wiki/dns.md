# DNS

- [DNS hijacking](https://openwrt.org/docs/guide-user/firewall/fw3_configurations/intercept_dns)
- [fw4 Filtering traffic with IP sets by DNS](https://openwrt.org/docs/guide-user/firewall/filtering_traffic_at_ip_addresses_by_dns)

## zeroconf: mDNS

- [mDNS repeater using mdnsd / mDNSresponder?](https://forum.openwrt.org/t/mdns-repeater-using-mdnsd-mdnsresponder/53112)
  - openwrt implements mdns with 3 different implementations:
  - `umdns`
  - `avahi`
    - [openwrt/packages/libs/avahi](https://github.com/openwrt/packages/tree/master/libs/avahi)
  - `mdnsd` + `mDNSResponder`
