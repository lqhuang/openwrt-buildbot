# Firewall

- [Firewall overview](https://openwrt.org/docs/guide-user/firewall/overview)
  - The `option syn_flood 1` or `option mtu_fix 1` each translate to complex
    nftables rules.
  - The `option masq 1` translates to the '-j MASQUERADE' target for NAT.
  - `mangle` rules that match bits in the packets TCP header and then modify the
    packet.
- [Firewall configuration /etc/config/firewall](https://openwrt.org/docs/guide-user/firewall/firewall_configuration)
  - A minimal firewall configuration for a router usually consists of one
    `defaults` section, at least two zones (`lan` and `wan`), and one
    `forwarding` to allow traffic from `lan` to `wan`.
  - The `forwarding` section is not strictly required when there are no more
    than two zones, as the rule can then be set as the 'global default' for that
    zone.
- [fw4 Filtering traffic with IP sets by DNS](https://openwrt.org/docs/guide-user/firewall/filtering_traffic_at_ip_addresses_by_dns)
- [Use nftables tracing to debug fw4 rules (22.03 and later)](https://openwrt.org/docs/guide-user/firewall/netfilter_iptables/netfilter_management)
- [IPv6 firewall examples](https://openwrt.org/docs/guide-user/firewall/fw3_configurations/fw3_ipv6_examples)
- [Firewall usage guide](https://openwrt.org/docs/guide-user/firewall/fw3_configurations/fw3_config_guide)
  - One possible pattern for rule names is: `target-port-source-dest`
  - eg: ACCEPT a SSH request from any device in the WAN zone of the router to
    any device in the LAN zone.
  - `option name 'ACCEPT-SSH-WAN-LAN'`

## sections for /etc/config/firewall

Basic components of the firewall configuration:

- `defaults`: The `defaults` section declares global firewall settings which do
  not belong to specific zones:
- `zone`: A `zone` section groups one or more _interfaces_ and serves as a
  source or destination for _forwardings_, _rules_ and _redirects_.
- `forwarding`: The `forwarding` sections control the traffic flow between zones
  - Only one direction is covered by a `forwarding` rule. To allow
    **bidirectional** traffic flows between two zones, two forwardings are
    required, with `src` and `dest` reversed in each.
- `rule`: The `rule` section is used to define basic accept, drop, or reject
  rules to allow or restrict access to specific ports or hosts.
- `redirect`: Port forwardings (DNAT) are defined by `redirect` sections. Port
  Redirects are also commonly known as "port forwarding" or "virtual servers".
- `ipset`: `fw4` supports referencing or creating IP sets to simplify matching
  of large address or port lists without the need for creating one rule per item
  to match.
- `include`: includes additional configuration files
  - support types: `nftables`, `script`,

## Tips

- `fw4 print`: you will see a number of netfilter/nftables rules either not
  explicitly defined in the firewall configuration files, or more difficult to
  understand

## Troubleshooting

### Problem: changes of configuration are not applied after tuning firewall rules

Try to reload firewall rules manually:

```
fw4 reload
```
