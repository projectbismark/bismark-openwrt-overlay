#!/bin/bash
#
# Given a directory, make a Packages.gz for every subdirectory containing any
# ipk files.

set -e

pkg_dir=$1
if [ -z $pkg_dir ] || [ ! -d $pkg_dir ]; then
	echo "Usage: ipkg-make-index-tree <package_directory>"
	exit 1
fi

# Figure out the directory where this script is stored. (Not necessary the same
# as the current working directory!) We use this to locate ipkg-make-index,
# which we assume is stored in the same direcotry as ipkg-make-index-tree.
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Find all subdirectories with packages and generate a Packages.gz for each.
find $pkg_dir -name "*.ipk" | xargs -n 1 dirname | sort -u | while read -r directory; do
	echo "Creating $directory/Packages.gz"
	(cd $directory && $script_dir/ipkg-make-index.sh . | gzip > Packages.gz)
done
