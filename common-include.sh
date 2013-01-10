#!/bin/bash

#
# common-include.sh
#
# Common variable initializations and function definitions.
#

BNCHMNT="/mnt/btrfs"
BSUBVOL="bsubvol"
GITSRCARCHIVE="/mnt/linux-stable.tar.bz2"
BASE_LINUX_SOURCES_SUBVOL="linux-stable"
TIMEBIN="/usr/bin/time"
BTRFSBIN="/usr/local/bin/btrfs"

# !!!***IMPORTANT***!!!
# The device designated as the TARGET *MUST* be a scratch device.
# Portions of the testing code will automatically reformat this
# device, so make sure there is nothing on this device that needs
# to be preserved.
TARGET="/dev/sda5"

echoit() { echo "$@" ; "$@" ; }
