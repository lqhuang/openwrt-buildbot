# Pre-init and boot process

- [Procd system init and daemon management](https://openwrt.org/docs/techref/procd)
- [Preinit and Root Mount and Firstboot Scripts](https://openwrt.org/docs/techref/preinit_mount)
- [The Boot Process](https://openwrt.org/docs/techref/process.boot)
- [Boot/Init Requirements](https://openwrt.org/docs/techref/requirements.boot.process)

## Configuration in scripts

To be able to load UCI configuration files, you need to include the common functions with:

```
. /lib/functions.sh
```

Then you can use `config_load name` to load config files.

- [Configuration in scripts](https://openwrt.org/docs/guide-developer/config-scripting)
