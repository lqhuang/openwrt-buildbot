#!/bin/sh

# https://openwrt.org/docs/guide-user/network/zeroconfig/zeroconf#umdns
# Even if the service comes with the base install, it must be enabled and started:

/etc/init.d/umdns enable
/etc/init.d/umdns start
