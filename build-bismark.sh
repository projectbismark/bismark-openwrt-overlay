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
BISMARK_RELEASE="quirm2"
WEB_ROOT=/data/users/bismark/builds
OPENWRT_TAG="backfire_10.03.1"
FEEDS_BISMARK_PACKAGES_REV="dfe318f8cc24606f7ce47d9bc34fc434da5d2684"
FEEDS_LUCI_BISMARK_REV="4fc56b03424275b6a54ae8143b5dcf474536267c"

# DON'T CHANGE THINGS BELOW HERE UNLESS YOU KNOW WHAT YOU'RE DOING

set -o errexit
set -o nounset

# git_checkout:
# checkout a repo to the specified ref at the specified path, and clone from
# the URL if it doesn't exist
#
# $1: Local path
# $2: Repo URL
# $3: Commit ref
git_checkout()
{
    ([ ! -z "${1:-}" ] && [ ! -z "${2:-}" ] && [ ! -z "${3:-}" ]) || \
            (echo "checkout requires 3 arguments." && exit 1)
    thepwd="$PWD"
    if [ -d "$PWD/$1/.git" ]; then
        cd "$PWD/$1"
        git pull
    else
        rm -rf "$PWD/$1"
        git clone $2 $1
        cd "$PWD/$1"
    fi
    git checkout $3
    cd $thepwd
}

# Sanity test -- check that build dir name is equal to release name
fullpath="$PWD/$0"
path=$(dirname $fullpath)
abspath=$(cd $path; pwd)
builddir=$(basename $abspath)
if [ $builddir != $BISMARK_RELEASE ]; then
    echo "Build directory '$builddir' does not match release name '$BISMARK_RELEASE'."
    echo "This is probably not what you want. Terminating."
    echo "(edit BISMARK_RELEASE in build-bismark.sh to fix this.)"
    exit 1
fi

# Computed build parameters
BISMARK_PRETTY_RELEASE=$(echo $BISMARK_RELEASE | \
        awk '{print toupper(substr($0,1,1)) substr($0,2)}')
BISMARK_SHORTHASH=$(git log -n 1 --pretty=format:%h HEAD)
BISMARK_HASH=$(git log -n 1 --pretty=format:%H HEAD)
BISMARK_BUILD_DATE=$(date -u  --iso-8601=seconds)

param_files="files/etc/issue
             files/etc/banner
             files/etc/opkg.conf"

# Checkout buildroot
svn co svn://svn.openwrt.org/openwrt/tags/$OPENWRT_TAG . --force

# Clone BISmark package repos
mkdir -p bismark-feeds
git_checkout bismark-feeds/bismark-packages \
             git://github.com/projectbismark/bismark-packages.git \
             $FEEDS_BISMARK_PACKAGES_REV
git_checkout bismark-feeds/luci-bismark \
             git://github.com/projectbismark/luci-bismark.git \
             $FEEDS_LUCI_BISMARK_REV

# Prepare buildroot
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

# Start building
make -j 4

WEB_DIR=$WEB_ROOT/$BISMARK_RELEASE
scripts/release-to-www.sh $WEB_DIR
