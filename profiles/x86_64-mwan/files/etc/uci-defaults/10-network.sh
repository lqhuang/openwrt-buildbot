#!/bin/sh

#
# Only for NAT6
#

# Enable IPv6 masquerading on the upstream zone.
uci set firewall.@zone[1].masq6="1"
uci commit firewall

# Requires sourcefilter=0 for DHCPv6 interfaces with missing GUA prefix.
# How?

# End of Only for NAT6