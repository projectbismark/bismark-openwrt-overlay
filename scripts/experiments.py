#!/usr/bin/env python
#
# Write global and per-device experiment configuration files.
#
# You should run this script any time you change experiment_mappings.conf or
# experiments.conf.

from collections import defaultdict
import errno
from optparse import OptionParser
import os
import re
import sys

def parse_args():
    script_path = os.path.dirname(os.path.realpath(__file__))
    parser = OptionParser()
    parser.add_option('-e', '--experiments', dest='experiments',
                      default=os.path.join(script_path, 'experiments.conf'),
                      help='File containing list of all Experiments')
    parser.add_option('-d', '--device-assignments', dest='devices',
                      default=os.path.join(script_path, 'experiment_mappings.conf'),
                      help='File containing device-to-experiment mapping')
    options, args = parser.parse_args()
    if len(args) != 1:
        parser.error('Expect one non-flag argument (the destination directory)')
    return args[0], options

# Example configuration file:
#  
#  config 'experiment' 'RequiredExperiment1'
#      option 'display_name' 'A Required BISmark Experiment'
#      option 'description' 'This experiment is mandatory for all BISmark users.'
#      option 'required' '1'
#      list 'package' 'first-package'
#      list 'package' 'second-package'
#
#  config 'experiment' 'AnOptionalExperiment'
#      option 'display_name' 'An Optional BISmark Experiment'
#      option 'description' 'This experiment is optional. Users may enable it in LuCI.'
#      list 'package' 'first-package'
#      list 'package' 'second-package'
#
# The experiment name ('RequiredExperiment1' and 'AnOptionalExperiment' in the
# example) must be unique among all experiments.
def parse_experiments(filename):
    experiments = defaultdict(list)
    for line in open(filename, 'r'):
        match = re.match(r"config 'experiment' '(.*?)'", line)
        if match is not None:
            current_experiment = match.group(1)
        if current_experiment is None:
            continue
        experiments[current_experiment].append(line)
    return experiments

# Example mappings files:
#
#  global
#   RequiredExperiment1
#
#  # This is a comment.
#  OW0123456789AB
#  OWBA9876543210
#    AnOptionalExperiment
#    AnotherExperiments
#
# The 'global' mapping will be available to all routers. 
def parse_experiment_mappings(filename):
    devices = defaultdict(list)
    device_matched = False
    current_devices = []
    for line in open(filename, 'r'):
        if re.match(r'\s*#', line) is not None:
            continue

        device_match = re.match(r'(\S+)\s*$', line)
        if device_match is not None:
            if not device_matched:
                current_devices = []
            current_devices.append(device_match.group(1))
            device_matched = True
        else:
            device_matched = False

        if current_devices != []:
            name_match = re.match(r'\s+(\S+)\s*$', line)
            if name_match is not None:
                name = name_match.group(1)
                for current_device in current_devices:
                    devices[current_device].append(name)
    return devices

def main():
    destination_dir, options = parse_args()

    experiments = parse_experiments(options.experiments)
    devices = parse_experiment_mappings(options.devices)

    for device, exps in devices.items():
        if device == 'global':
            output_path = os.path.join(
                    destination_dir, 'experiments', 'Experiments')
        else:
            output_path = os.path.join(
                    destination_dir, 'experiments-device', device, 'Experiments')
        try:
            os.makedirs(os.path.dirname(output_path))
        except OSError, e:
            if e.errno != errno.EEXIST:
                raise
        print 'Writing', output_path
        handle = open(output_path, 'w')
        for experiment in exps:
            handle.write(''.join(experiments[experiment]))
        handle.close()

if __name__ == '__main__':
    main()
