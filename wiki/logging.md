# Read std openwrt logs

- [Logging messages](https://openwrt.org/docs/guide-user/base-system/log.essentials)

```sh
# List syslog
logread

# Write a message with a tag to syslog
logger -t TAG MESSAGE

# List syslog filtered by tag
logread -e TAG
```
