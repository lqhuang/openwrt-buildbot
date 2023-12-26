#!/bin/sh

# uci -q batch << EOI
# set network.lan.ipaddr='192.168.178.1'
# set wireless.@wifi-device[0].disabled='0'
# set wireless.@wifi-iface[0].ssid='OpenWrt0815'
# add dhcp host
# set dhcp.@host[-1].name='bellerophon'
# set dhcp.@host[-1].ip='192.168.2.100'
# set dhcp.@host[-1].mac='a1:b2:c3:d4:e5:f6'
# rename firewall.@zone[0]='lan'
# rename firewall.@zone[1]='wan'
# rename firewall.@forwarding[0]='lan_wan'
# EOI

# uci -q show system.@rngd[0] || {
#     uci add system rngd
#     uci set system.@rngd[0].enabled=0
#     uci set system.@rngd[0].device=/dev/urandom
#     uci commit system
# }
