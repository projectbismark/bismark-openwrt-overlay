#!/usr/bin/env bash

config_file=scripts/special-packages.conf
delim=" "
base_dir=`pwd`
build_dir="bin/ar71xx"
dirs="packages updates experiments"
awk '/^[[:alnum:]\-]+ [[:alnum:]\-]+[ ]*$/' $config_file | while read i; do
	package=`echo $i | cut -d"$delim" -f1`
	dir=`echo $i | cut -d"$delim" -f2`	
	echo $package $dir
	mv -f "$base_dir"/"$build_dir"/packages/$package_*.ipk "$base_dir"/"$build_dir"/"$dir"
done
for dir in $dirs; do
	cd "$base_dir"/"$build_dir"/"$dir"
	"$base_dir"/scripts/ipkg-make-index.sh . | gzip > Packages.gz
done
