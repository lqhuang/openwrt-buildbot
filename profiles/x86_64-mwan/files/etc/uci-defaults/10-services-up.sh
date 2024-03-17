#!/bin/sh

# https://openwrt.org/docs/guide-user/network/zeroconfig/zeroconf#umdns
# Even if the service comes with the base install, it must be enabled and started:
service umdns enable
service umdns start

service irqbalance enable
service irqbalance start

#service adguardhome enable
#service adguardhome start

# By default, NTP client is enabled and NTP server is disabled.
