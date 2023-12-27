# Troubleshooting

## Problem:

Execute `make world V=sc` to build the whole system, but failed.

```sh
make world V=sc
```

Error msg:

```plain
....
checking whether mkfifo rejects trailing slashes... yes
checking whether mkfifoat rejects trailing slashes... yes
checking whether mknod can create fifo without root privileges... configure: error: in `<buildroot>/build_dir/host/tar-1.34':
configure: error: you should not run configure as root (set FORCE_UNSAFE_CONFIGURE=1 in environment to bypass this check)
See `config.log' for more details
make[3]: *** [Makefile:36: <buildroot>/build_dir/host/tar-1.34/.configured] Error 1
make[3]: Leaving directory '<buildroot>/tools/tar'
time: tools/tar/compile#9.41#3.23#15.94
    ERROR: tools/tar failed to build.
make[2]: *** [tools/Makefile:226: tools/tar/compile] Error 1
make[2]: Leaving directory '<buildroot>'
...
```

Solution

1. there is no need to build as root. (Why I saw once docs saying that we should
   build as root?)
   > Do everything as an unprivileged user, not root, without sudo. --
   > [Build system usage](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
2. If build as root, set env by `export FORCE_UNSAFE_CONFIGURE=1` before
   `make world V=sc`
