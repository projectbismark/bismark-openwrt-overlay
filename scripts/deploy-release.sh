#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "Usage: $0 [destination directory]"
	exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_ROOT=$(readlink -f "$SCRIPT_DIR/..")
DEST_DIR=$1

echo "You are about to deploy an OpenWRT build."
echo "Source: $BUILD_ROOT"
echo "Destination: $DEST_DIR"
echo "This will copy all packages and experiments from the build tree."
echo "DO NOT RUN THIS COMMAND ON AN UPDATES BUILD TREE. Run deploy-updates.sh instead."
read -p "Are you sure you want to continue? (yN) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Aborting."
	exit
fi

echo "Step 1: Copy images"
mkdir -p $DEST_DIR/ar71xx
cp $BUILD_ROOT/bin/ar71xx/openwrt-bismark-*-sysupgrade*.bin $DEST_DIR/ar71xx
cp $BUILD_ROOT/bin/ar71xx/openwrt-bismark-*-factory*.img $DEST_DIR/ar71xx

echo "Step 2: Copy packages"
$SCRIPT_DIR/copy-packages.py $DEST_DIR/ar71xx -t experiments,packages

echo "Step 3: Generate package indices"
$SCRIPT_DIR/ipkg-make-index-tree.sh $DEST_DIR/ar71xx

echo "Step 4: Touch Upgradable files"
$SCRIPT_DIR/touch-upgradable-tree.sh $DEST_DIR/ar71xx

echo "Step 5: Write experiment configurations"
$SCRIPT_DIR/experiments.py $DEST_DIR/ar71xx
