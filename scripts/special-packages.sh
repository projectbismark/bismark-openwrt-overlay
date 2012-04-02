#!/usr/bin/env bash

if [ "x$1" == "x" ]; then
    dest_dir="$PWD/bin/ar71xx"
else
    dest_dir="$1"
fi
config_file=scripts/special-packages.conf
delim=" "
base_dir=$PWD
dirs="packages updates experiments"
awk '/^[[:alnum:]\-]+ [[:alnum:]\-]+[ ]*$/' $config_file | sort -u | while read i; do
	package=`echo $i | cut -d"$delim" -f1`
	dir=`echo $i | cut -d"$delim" -f2`	
	mkdir -p $dest_dir/$dir
	touch $dest_dir/$dir/Upgradable
	echo Moving $package to $dir
	mv -f $base_dir/bin/ar71xx/packages/${package}_*.ipk $dest_dir/$dir/
done
for dir in $dirs; do
	mkdir -p $dest_dir/$dir
	(cd $dest_dir/$dir && $base_dir/scripts/ipkg-make-index.sh . | gzip > Packages.gz)
done
