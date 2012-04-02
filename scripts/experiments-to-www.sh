#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "Usage: $0 [destination directory]"
	exit 1
fi

DEST_DIR=$1
mkdir -p $DEST_DIR/ar71xx
scripts/special-packages.sh $DEST_DIR/ar71xx
scripts/experiments.py --output-directory=$DEST_DIR/ar71xx
