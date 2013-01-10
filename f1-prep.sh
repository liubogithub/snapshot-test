#!/bin/bash

#
# f1-prep.sh
#
# Prepare a test partition for linux source snapshot testing.
#

#BASEDIR="${0%/*}"
BASEDIR=`pwd`

source "${BASEDIR}/common-include.sh"

TIMESLOT=$(date '+%Y%m%d-%H%M%S')

cat /proc/version
cat /proc/cmdline
echo "TIMESLOT is ${TIMESLOT}"

if (cat /proc/mounts | grep "${BNCHMNT}"); then
	echo "${BNCHMNT} mountpoint is mounted..."

	if [[ -e "${BASE_LINUX_SOURCES_SUBVOL}/MAINTAINERS" ]]; then
		echo "The sources seem to already be present!"
		echo "Exiting..."
		exit 1
	fi
else
	echo "Mount ${BNCHMNT} not found, formatting and mounting..."

	# Reformat the testing partition.
	${BASEDIR}/reformat-testing-partition.sh

	echoit mount -o autodefrag,compress-force=lzo ${TARGET} ${BNCHMNT}
fi

if [[ ! -e ${GITSRCARCHIVE} ]]; then
	echo "Git source archive ${GITSRCARCHIVE} not found! exiting!!!"
	exit 1
fi

CMDS="${TIMEBIN} ${BTRFSBIN} tar sync"
for i in $CMDS; do
	# command -v will return >0 when the $i is not found
	command -v $i >/dev/null || { echo "$i command not found."; exit 1; }
done

cd  ${BNCHMNT}

# Create a working subvolume for the base git sources and the snapshots.
${BTRFSBIN} subvolume create ./linux-stable
${BTRFSBIN} subvolume create ./bsubvol

# Extract the sources to the root directory on the testing partition.
echo "Dearchiving git source dirs to ${BNCHMNT}..."
${TIMEBIN} tar -xpf ${GITSRCARCHIVE} -C "${BASE_LINUX_SOURCES_SUBVOL}"
sync

# All the branches that will be used for pulls need to be checked out
# or they won't be found.
cd "${BASE_LINUX_SOURCES_SUBVOL}"
git checkout linux-2.6.37.y 

# Display some general status information 
df -T ${BNCHMNT}

${BTRFSBIN} filesystem df ${BNCHMNT}
