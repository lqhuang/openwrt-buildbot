# Use the Image Builder to create a custom image

- [Using the Image Builder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder)
- [Quick image building guide](https://openwrt.org/docs/guide-developer/toolchain/beginners-build-guide)

## Install prerequisites

```sh
apt install build-essential clang g++ gcc-multilib g++-multilib \
libncurses-dev libncursesw-dev libssl-dev zlib1g-dev \
flex bison gawk git gettext xsltproc rsync curl wget unzip python3
```

## Setup openwrt imagebuilder

```
$ make help

Available Commands:
	help:	This help text
	info:	Show a list of available target profiles
	clean:	Remove images and temporary build files
	image:	Build an image (see below for more information).
	manifest: Show all package that will be installed into the image
	package_whatdepends: Show which packages have a dependency on this
	package_depends: Show installation dependency of the package

image:
	By default 'make image' will create an image with the default
	target profile and package set. You can use the following parameters
	to change that:

	make image PROFILE="<profilename>" # override the default target profile
	make image PACKAGES="<pkg1> [<pkg2> [<pkg3> ...]]" # include extra packages
	make image FILES="<path>" # include extra files from <path>
	make image BIN_DIR="<path>" # alternative output directory for the images
	make image EXTRA_IMAGE_NAME="<string>" # Add this to the output image filename (sanitized)
	make image DISABLED_SERVICES="<svc1> [<svc2> [<svc3> ..]]" # Which services in /etc/init.d/ should be disabled
	make image ADD_LOCAL_KEY=1 # store locally generated signing key in built images
	make image ROOTFS_PARTSIZE="<size>" # override the default rootfs partition size in MegaBytes

manifest:
	List "all" packages which get installed into the image.
	You can use the following parameters:

	make manifest PROFILE="<profilename>" # override the default target profile
	make manifest PACKAGES="<pkg1> [<pkg2> [<pkg3> ...]]" # include extra packages
	make manifest STRIP_ABI=1 # remove ABI version from printed package names

package_whatdepends:
	List "all" packages that have a dependency on this package
	You can use the following parameters:

	make package_whatdepends PACKAGE="<pkg>"

package_depends:
	List "all" packages dependency of the package
	You can use the following parameters:

	make package_depends PACKAGE="<pkg>"

```
