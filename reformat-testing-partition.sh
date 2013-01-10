#!/bin/bash

#
# Run mkfs on the testing partition, sdb6
#

BASEDIR="${0%/*}"

source "${BASEDIR}/common-include.sh"

echoit mkfs.btrfs -m single ${TARGET}
# echoit mkfs.btrfs -m single -l 8192 -n 8192 ${TARGET}
#echoit mkfs.btrfs -m single -l 16384 -n 16384 ${TARGET}
# echoit mkfs.btrfs -m single -l 65536 -n 65536 ${TARGET}
