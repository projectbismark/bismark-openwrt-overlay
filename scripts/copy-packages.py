#!/usr/bin/env python
#
# Copy ipk packages from the build tree into another directory tree.
# A package's path in the destination tree depends on whether it is
# part of an experiment, as specified by special-packages.conf.
#
# For example, if special-packages.conf contains:
#
#  package1 experiments
#  package2 updates
#  package2 packages
#
# And bin/ar71xx/packages contains:
#
#  package1_ver1.ipk
#  package2_ver1.ipk
#  package3_ver1.ipk
#  package4_ver1.ipk
#
# Then these packages will be copied to the destination as follows:
#
#  destination/experiments/package1_ver1.ipkg
#  destination/updates/package2_ver1.ipkg
#  destination/packages/package3_ver1.ipkg
#  destination/packages/package4_ver1.ipkg
#
# Packages absent from special-packages.conf get copied to the "packages" directory.
#
# To deploy a new build tree:
#
#  scripts/copy-packages.py /data/users/bismark/downloads/$BUILD_NAME/ar71xx/bin -t packages,experiments
#
# To deploy updates to an existing build tree:
#
#  scripts/copy-packages.py /data/users/bismark/downloads/$BUILD_NAME/ar71xx/bin -t updates,experiments

import errno
import glob
from optparse import OptionParser
import os
import re
import shutil
import StringIO
import subprocess
import tarfile

def parse_args():
    script_path = os.path.dirname(os.path.realpath(__file__))
    parser = OptionParser()
    parser.add_option('-c', '--special-packages-configuration', dest='configuration',
                      default=os.path.join(script_path, 'special-packages.conf'),
                      help='File listing packages in experiments and updates')
    parser.add_option('-p', '--packages-directory', dest='packages_dir',
                      default=os.path.realpath(os.path.join(script_path, '../bin/ar71xx/packages')),
                      help='Copy packages from this directory')
    parser.add_option('-t', '--package-types', dest='package_types',
                      default='experiments,packages',
                      help='Only copy these types of packages, as specified in special-packages.conf')
    (options, args) = parser.parse_args()
    if len(args) != 1:
        parser.error('Expect one non-flag argument (the destination directory)')
    return args[0], options

# Example configuration file:
#
#   package1 experiments
#   package2 packages	 # Comment
#   # Another comment
def parse_configuration(filename):
    directories = {}
    for line in open(filename, 'r'):
        m = re.match(r'(?P<package>[a-zA-Z0-9\-]+)\s+(?P<dir>[a-zA-Z0-9\-]+)', line)
        if m is None:
            continue
        directories[m.group('package')] = m.group('dir')
    return directories

# Extract a package's name from the package manifest. This
# requires extracting a nested tar file
# (i.e., package.ipk:control.tar.gz:control is the manifest.)
def get_package_name(filename):
    package_handle = tarfile.open(filename)
    control_handle = package_handle.extractfile('./control.tar.gz')
    control_tar_handle = tarfile.open(fileobj=control_handle, mode='r:gz')
    for line in control_tar_handle.extractfile('./control'):
        words = line.split()
        if words == []:
            continue
        if words[0] != "Package:":
            continue
        return words[1]
    return None

def copy_package(package_types, directories, filename, base_destination):
    package_name = get_package_name(filename)
    if package_name is None:
        return
    package_type = directories.get(package_name, 'packages')
    if package_type not in package_types.split(','):
        return
    destination_dir = os.path.join(base_destination, package_type)
    try:
        os.makedirs(destination_dir)
    except OSError, e:
        if e.errno != errno.EEXIST:
            raise
    print 'Copying %s to %s' % (filename, destination_dir)
    shutil.copy2(filename, destination_dir)

def main():
    destination_dir, options = parse_args()
    directories = parse_configuration(options.configuration)
    for filename in glob.glob(os.path.join(options.packages_dir, '*.ipk')):
        copy_package(options.package_types, directories, filename, destination_dir)

if __name__ == '__main__':
    main()
