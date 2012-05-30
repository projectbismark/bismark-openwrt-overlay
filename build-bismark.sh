#!/bin/sh
#
# Make sure you have the tools to build packages: Follow Step 1 (only)
# from here: http://wiki.openwrt.org/doc/howto/buildroot.exigence
#
# First run this command manually:
#   git clone https://github.com/projectbismark/bismark-openwrt-overlay.git $BUILDROOT
#
# where BUILDROOT is something like "quirm-rc3"

# Build parameters
BISMARK_RELEASE="fourecks"
WEB_ROOT=/data/users/bismark/builds

set -o errexit
set -o nounset


# Computed build parameters
BISMARK_PRETTY_RELEASE=$(echo $BISMARK_RELEASE | \
        awk '{print toupper(substr($0,1,1)) substr($0,2)}')
BISMARK_SHORTHASH=$(git log -n 1 --pretty=format:%h HEAD)
BISMARK_HASH=$(git log -n 1 --pretty=format:%H HEAD)
BISMARK_BUILD_DATE=$(date -u  --iso-8601=seconds)

svn co svn://svn.openwrt.org/openwrt/tags/backfire_10.03.1 . --force
param_files="files/etc/issue
             files/etc/banner
             files/etc/opkg.conf"

./scripts/feeds update
git checkout -- .config
./scripts/feeds install -a

# Substitute parameters in each of param_files
for file in $param_files; do
    git checkout -- $file
    sed -i "s/BISMARK_RELEASE/$BISMARK_RELEASE/g; \
            s/BISMARK_PRETTY_RELEASE/$BISMARK_PRETTY_RELEASE/g; \
            s/BISMARK_HASH/$BISMARK_HASH/g; \
            s/BISMARK_SHORTHASH/$BISMARK_SHORTHASH/g; \
            s/BISMARK_BUILD_DATE/$BISMARK_BUILD_DATE/g" $file
done

make -j 4

WEB_DIR=$WEB_ROOT/$BISMARK_RELEASE
scripts/release-to-www.sh $WEB_DIR
