#!/bin/sh
#
# Make sure you have the tools to build packages: Follow Step 1 (only)
# from here: http://wiki.openwrt.org/doc/howto/buildroot.exigence
#
# First run this command manually:
#   git clone https://github.com/projectbismark/bismark-openwrt-overlay.git $BUILDROOT
#
# where BUILDROOT is something like "quirm-rc3"

set -o errexit
set -o nounset

WEB_ROOT=/data/users/bismark/builds
RELEASE_NAME=$(sed -n '2p' files/etc/issue)

svn co svn://svn.openwrt.org/openwrt/tags/backfire_10.03.1 . --force
./scripts/feeds update
git checkout -- .config
./scripts/feeds install -a
git checkout -- files/etc/opkg.conf
sed -i "s/BISMARK-RELEASE/$RELEASE_NAME/" files/etc/opkg.conf
make -j 4

# Uncomment one of the following depending on whether you're making a base
# build or an updates build.
#scripts/deploy-release.sh $DEPLOY_ROOT/$RELEASE_NAME
#scripts/deploy-updates.sh $DEPLOY_ROOT/$RELEASE_NAME
