#!/usr/bin/env python

import errno
from optparse import OptionParser
import os
import re
import sys

def parse_args():
    parser = OptionParser()
    parser.add_option('-e', '--experiments', dest='experiments',
                      default='scripts/experiments.conf',
                      help='File containing list of all Experiments')
    parser.add_option('-d', '--device-assignments', dest='devices',
                      default='scripts/experiment_mappings.conf',
                      help='File containing device-to-experiment mapping')
    parser.add_option('-o', '--output-directory', dest='root',
                      default='bin/ar71xx',
                      help='Output directory')
    (options, args) = parser.parse_args()
    if args != []:
        parser.error('No positional arguments')
    return options

def main():
    options = parse_args()

    experiments = {}
    for line in open(options.experiments, 'r'):
        match = re.match(r"config 'experiment' '(.*?)'", line)
        if match is not None:
            current_experiment = match.group(1)
        if current_experiment is not None:
            try:
                experiments[current_experiment].append(line)
            except KeyError:
                experiments[current_experiment] = [line]

    devices = {}
    device_matched = False
    current_devices = []
    for line in open(options.devices, 'r'):
        if re.match(r'\s*#', line) is not None:
            continue

        device_match = re.match(r'(\S+)$', line)
        if device_match is not None:
            if not device_matched:
                current_devices = []
            current_devices.append(device_match.group(1))
            device_matched = True
        else:
            device_matched = False

        if current_devices != []:
            name_match = re.match(r'\s+(\S+)$', line)
            if name_match is not None:
                name = name_match.group(1)
                for current_device in current_devices:
                    try:
                        devices[current_device].append(name)
                    except KeyError:
                        devices[current_device] = [name]

    for device, exps in devices.items():
        if device == 'global':
            output_path = os.path.join(
                    options.root, 'experiments', 'Experiments')
        else:
            output_path = os.path.join(
                    options.root, 'experiments-device', device, 'Experiments')
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
