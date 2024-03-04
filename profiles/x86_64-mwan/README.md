# Multiple WANs

My OpenWrt config for dual ISPs

## Notes

1. 没有利用 `mwan3` 进行负载均衡
2. wan0 和 wan1 都是正常连接
   - IPv6 使用了 NAT66
3. 通过 `sing-box` 来深度定制负载均衡的策略
