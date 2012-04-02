#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "Usage: $0 [destination directory]"
	exit 1
fi

DEST_DIR=$1
BUILD_DIR=$PWD

mkdir -p $DEST_DIR/ar71xx/packages
cp bin/ar71xx/openwrt-bismark_*-sysupgrade*.bin $DEST_DIR/ar71xx
cp bin/ar71xx/openwrt-bismark_*-factory*.img $DEST_DIR/ar71xx
cp bin/ar71xx/packages/*.ipk $DEST_DIR/ar71xx/packages
(cd $DEST_DIR/ar71xx/packages && $BUILD_DIR/scripts/ipkg-make-index.sh . | gzip > Packages.gz)
