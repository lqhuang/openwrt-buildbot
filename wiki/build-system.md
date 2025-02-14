# Use build system to create a custom image

- [Build system essentials](https://openwrt.org/docs/guide-developer/toolchain/buildsystem_essentials)
- [Build system setup](https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem)
- [Build system usage](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
- [Using build environments](https://openwrt.org/docs/guide-developer/toolchain/env)
- [Overriding Build Options](https://openwrt.org/docs/guide-developer/packages.flags)
- [Building a single package](https://openwrt.org/docs/guide-developer/toolchain/single.package)
- [OpenWrt Feeds](https://openwrt.org/docs/guide-developer/feeds)
- [Build system usage](https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem)
- [Kernel related options](https://openwrt.org/docs/techref/buildroot)
- [Cryptographic Hardware Accelerators](https://openwrt.org/docs/techref/hardware/cryptographic.hardware.accelerators)

## Install prerequisites

```sh
apt install build-essential clang g++ gcc-multilib g++-multilib \
    libncurses-dev libssl-dev zlib1g-dev \
    flex bison gawk git gettext xsltproc rsync curl wget unzip python3
```

## Target

- Target System (x86)
- Subtarget (x86_64)
- Target Profile (Generic)

## Configure options

For most packages and features, you have three options: y, m, n which are
represented as follows:

- pressing `y` sets the `<*>` built-in label. This package will be compiled and
  included in the firmware image file.
- pressing `m` sets the `<M>` package label. This package will be compiled, but
  not included in the firmware image file, e.g. to be installed with opkg after
  flashing the firmware image file to the device.
- pressing `n` sets the `< >` excluded label. The source code will not be
  processed.

## Setp by step

### Get source code

```sh
git clone --depth 1 [--branch <version>] https://git.openwrt.org/openwrt/openwrt.git [<buildroot>]
```

> [!Warning]
>
> When changing branches, it is recommended to perform a thorough scrub of your
> source tree by using the `make distclean` command. This ensures that your
> source tree does not contain any build artifacts or configuration files from
> previous build runs.

### Updating feeds

```sh
# Pull the latest updates for the feeds in case it became outdated.
./scripts/feeds update -a
# Make the downloaded package/packages available in `make menuconfig` or `make defconfig`.
./scripts/feeds install -a
```

### Optional: Using official build config

Compile OpenWrt in a way that it gets the same packages as the default official
image

```sh
wget https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/config.buildinfo -O .config
# https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/feeds.buildinfo
# https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/profiles.json
```

When using this configuration the correct defaults will be already selected for
the Target and Subtarget but not for the Target profile so you will have to
tailor it for the specific device if you want to build only that one.

### Configure using config diff file

Beside `make menuconfig` another way to configure is using a configuration diff
file. This file includes only the changes compared to the default configuration.
A benefit is that this file can be version-controlled in your downstream
project. It's also less affected by upstream updates, because it only contains
the changes.

#### Creating diff file

Save the build config changes.

```sh
# Write the changes to diffconfig
./scripts/diffconfig.sh > diffconfig
```

#### Using diff file

These changes can form the basis of a config file `<buildroot>/.config`. By
running `make defconfig` these changes will be expanded into a full config.

```sh
# Write changes to .config
cp diffconfig .config

# Expand to full config
make defconfig
```

These changes can also be added to the bottom of the config file
(`<buildroot>/.config`), by running `make defconfig` these changes will
**override** the existing configuration.

```sh
# Append changes to bottom of .config
cat diffconfig >> .config

# Apply changes
make defconfig
```

### Custom files

In case you want to include some custom configuration files, the correct place
to put them is:

- `<buildroot>/files/`

For example, let's say that you want an image with a custom
`/etc/config/firewall` or a custom `etc/sysctl.conf`, then create this files as:

- `<buildroot>/files/etc/config/firewall`
- `<buildroot>/files/etc/sysctl.conf`

### Defconfig

```sh
make defconfig
```

will produce a default configuration of the target device and build system,
including a check of dependencies and prerequisites for the build environment.

Defconfig will also remove outdated items from `.config`, e.g. references to
non-existing packages or config options.

It also checks the dependencies and will add possibly missing necessary
dependencies. This can be used to "expand" a short `.config` recipe (like
diffconfig output, possible even pruned further) to a full `.config` that the
make process accepts.

### Optional: Kernel configuration

Note that make `kernel_menuconfig` modifies the Kernel configuration templates
of the build tree and clearing the build_dir will not revert them. :warning:
Also you won't be able to install kernel packages from the official repositories
when you make changes here.

While you won't typically need to do this, you can do it:

```sh
make kernel_menuconfig CONFIG_TARGET=subtarget
```

`CONFIG_TARGET` allows you to select which config you want to edit, possible
options: `target`, `subtarget`, `env`.

The changes can be reviewed and reverted with:

```sh
git diff target/linux/
git checkout target/linux/
```

### Download sources and multi core compile

Before running final make it is best to issue make download command first, this
step will pre-fetch all source code for all dependencies, this enables you
compile with more CPU cores, e.g. `make -j10`, for 4 core, 8 thread CPU works
great.

If you try compiling OpenWrt on multiple cores and don't download all source
files for all dependency packages it is very likely that your build will fail.

```sh
make download
```

### Building images

Everything is now ready for building the image(s), which is done with one single
command:

```sh
make
```

This should compile

1. toolchain
2. cross-compile sources
3. package packages

and generate an image ready to be flashed

### Locating images

After a successful build, the freshly built image(s) can be found below the
newly created `<buildroot>/bin` directory. The compiled files are additionally
classified by the target platform and subtarget

### Clean

- `make clean`: Deletes contents of the directories `/bin` and `/build_dir`.
  This doesn't remove the toolchain, and it also avoids cleaning
  architectures/targets other than the one you have selected in your `.config`.
  It is a good practice to do `make clean` before a build to ensure that no
  outdated artefacts have been left from the previous builds. That may not be
  necessary always, but as a general rule it helps to ensure quality builds.
- `make targetclean`: This cleans also the target-specific toolchain in addition
  of doing `make clean`. This may be needed when the toolchain components like
  musl or gcc change. Does a `make clean` and deletes also the directories
  `/build_dir/toolchain*` and `/staging_dir/toolchain*` (= the cross-compile
  tools).
- `make dirclean`: This is your basic "full clean" operation. Cleans all
  compiled binaries, tools, toolchain, tmp etc. `/bin` and `/build_dir` and
  `/staging_dir` (= tools and the cross-compile toolchain), `/tmp` (e.g data
  about packages) and `/logs`
- `make distclean`: Nukes everything you have compiled or configured and also
  deletes all downloaded feeds contents and package sources. :warning: In
  addition to all else, this will erase your build configuration
  `<buildroot>/.config`. Use only if you need a “factory reset” of the build
  system!
- selective clean for specific objects
  - `make target/linux/clean`
  - `make package/base-files/clean`
  - `make package/luci/clean`

## Speedup building

### Using prebuilt toolchains

### Using `ccache`

- https://github.com/openwrt/buildbot/blob/main/scripts/ccache.sh

### Other cacheable artifacts

- https://github.com/stupidloud/cachewrtbuild

## Tips

### Building a single package

Try install deps first

```
make tools/install
make toolchain/install
```

then

```
make package/nucrses/compile
```

Ref:

- [Toolchain / Building a single package](https://openwrt.org/docs/guide-developer/toolchain/single.package)

### Warnings, errors and tracing

The parameter `V=x` specifies level of messages in the process of the build.

    V=99 and V=1 are now deprecated in favor of a new verbosity class system,
    though the old flags are still supported.
    You can set the V variable on the command line (or OPENWRT_VERBOSE in the
    environment) to one or more of the following characters:

    - s: stdout+stderr (equal to the old V=99)
    - c: commands (for build systems that suppress commands by default, e.g. kbuild, cmake)
    - w: warnings/errors only (equal to the old V=1)

### Spotting build errors

If for some reason the build fails, the easiest way to spot the error is to do:

```sh
make V=s 2>&1 | tee build.log | grep -i -E "^make.*(error|[12345]...Entering dir)"

make V=s 2>&1 | tee build.log | grep -i '[^_-"a-z]error[^_-.a-z]'
(may not work)
```

The above saves a full verbose copy of the build output (with stdout piped to
stderr) in `~/source/build.log` and shows errors on the screen (along with a few
spurious instances of 'error').

### Make a summary information of generated image

```sh
make json_overview_image_info
```

Generate a summary of the image (including default packages, type of target,
etc...) in JSON format. The output is available in `<BUILD_DIR>/profiles.json`.

### Calculate checksum for generated files

```sh
make checksum
```

The following action will take place: a checksum will be computed and saved for
the output files. This checksum will then be stored in the
`<BIN_DIR>/sha256sums`.

### Compilation errors

Some packages may not be updated properly and built after they got stuck with
old dependencies, resulting in warnings at the beginning of the compilation
looking similar to:

```
WARNING: Makefile 'package/feeds/packages/openssh/Makefile' has a dependency on 'libfido2', which does not exist
```

The build environment can be recovered by uninstalling and reinstalling the
failing package

```
$ ./scripts/feeds uninstall openssh
Uninstalling package 'openssh'
$ ./scripts/feeds install openssh
Installing package 'openssh' from packages
Installing package 'libfido2' from packages
Installing package 'libcbor' from packages
```
