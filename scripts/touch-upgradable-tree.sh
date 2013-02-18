#!/bin/bash
#
# Given a directory, touch a file called Upgradable in every subdirectory
# containing ipk files. An Upgradable file tell bismark-updater that it's safe
# upgrade packages from that directory. (We want to avoid upgrading from
# repositories we do not control. Yes, this is very insecure, but we're
# already trusting the OpenWRT folks quite a bit.)

set -e

pkg_dir=$1
if [ -z $pkg_dir ] || [ ! -d $pkg_dir ]; then
	echo "Usage: $0 <package_directory>"
	exit 1
fi

# Find all subdirectories with packages and generate a Packages.gz for each.
find $pkg_dir -name "*.ipk" | xargs -n 1 dirname | sort -u | while read -r directory; do
	echo "Touching $directory/Upgradable"
	touch $directory/Upgradable
done
