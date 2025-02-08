# Utils

## Control and Config

- https://openwrt.org/docs/guide-user/base-system/managing_services
- https://openwrt.org/docs/guide-user/base-system/hotplug
- https://openwrt.org/docs/guide-user/base-system/cron

## NTP client

- https://openwrt.org/docs/guide-user/advanced/ntp_configuration
- https://openwrt.org/docs/guide-user/services/ntp/client
- https://openwrt.org/docs/guide-user/services/ntp/client-server

## Random Generator

- https://openwrt.org/docs/guide-user/services/rng

## AdGuard Home

- [AdGuard Home](https://openwrt.org/docs/guide-user/services/dns/adguard-home)
- [OpenWrt AdGuard Home 101 (DNSMASQ)](https://forum.openwrt.org/t/openwrt-adguard-home-101-dnsmasq/110864)
- [DNS Interception](https://openwrt.org/docs/guide-user/services/dns/adguard-home#dns_interception)
  - In order to make sure all DNS traffic goes through your primary DNS
    resolver, you can enforce this through firewall rules.

> If AdGuard Home won't start, you will want to view error logs to understand
> why.
>
> If using the opkg package you can view syslog for errors using logread.

>     logread -e AdGuardHome

## ACME

- https://openwrt.org/docs/guide-user/services/tls/acmesh

## Grafana

- https://grafana.com/blog/2021/02/09/how-i-monitor-my-openwrt-router-with-grafana-cloud-and-prometheus/
- https://github.com/google/dnsmasq_exporter
- https://github.com/prometheus/collectd_exporter
- https://linuxcommunity.io/t/monitoring-openwrt-with-grafana-and-prometheus/1140
- https://github.com/benisai/Openwrt-Monitoring
- https://blog.christophersmart.com/2019/09/09/monitoring-openwrt-with-collectd-influxdb-and-grafana/
- https://grafana.com/docs/grafana-cloud/send-data/metrics/metrics-prometheus/prometheus-config-examples/openwrt-openwrt-packages/

## Nginx

- [OpenWrt Wiki - Accessing LuCI web interface securely](https://openwrt.org/docs/guide-user/luci/luci.secure): no description found
- [OpenWrt Wiki - Nginx webserver](https://openwrt.org/docs/guide-user/services/webserver/nginx)
