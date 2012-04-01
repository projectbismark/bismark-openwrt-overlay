#!/bin/sh
#
# Make sure you have the tools to build packages: Follow Step 1 (only)
# from here: http://wiki.openwrt.org/doc/howto/buildroot.exigence
#
# First run this command manually:
#   git clone https://github.com/projectbismark/bismark-openwrt-overlay.git $BUILDROOT
#
# where BUILDROOT is something like "quirm-rc3"
svn co svn://svn.openwrt.org/openwrt/tags/backfire_10.03.1 . --force
./scripts/feeds update
git checkout .config
./scripts/feeds install -a
make -j 4
scripts/special-packages.sh
scripts/experiments.py
