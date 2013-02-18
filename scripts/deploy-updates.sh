#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "Usage: $0 [destination directory]"
	exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_ROOT=$(readlink -f "$SCRIPT_DIR/..")
DEST_DIR=$1

echo "You are about to deploy OpenWRT package updates."
echo "Source: $BUILD_ROOT"
echo "Destination: $DEST_DIR"
echo "This will copy packages marked as updates in special-packages.conf."
echo "If you want to deploy a full OpenWRT build, deploy-release.sh instead."
read -p "Are you sure you want to continue? (yN) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo
	echo "Aborting."
	exit
fi

echo "Step 2: Copy packages"
$SCRIPT_DIR/copy-packages.py $DEST_DIR/ar71xx -t updates

echo "Step 3: Generate package indices"
$SCRIPT_DIR/ipkg-make-index-tree.sh $DEST_DIR/ar71xx

echo "Step 4: Touch Upgradable files"
$SCRIPT_DIR/touch-upgradable-tree.sh $DEST_DIR/ar71xx

echo "Step 5: Write experiment configurations"
$SCRIPT_DIR/experiments.py $DEST_DIR/ar71xx
