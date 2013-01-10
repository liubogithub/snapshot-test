#!/bin/bash

#
# f3-manipulate-snapshot.sh
#
# Create the first snapshot for linux source snapshot testing.
#

BASEDIR="${0%/*}"
source "${BASEDIR}/common-include.sh"
TIMESLOT=$(date '+%Y%m%d-%H%M%S')

cat /proc/version
cat /proc/cmdline
echo "TIMESLOT is ${TIMESLOT}"

if (cat /proc/mounts | grep "${BNCHMNT}"); then
	echo "${BNCHMNT} mountpoint is mounted..."
else
	echo "Mount ${BNCHMNT} not found, attempting to mount..."

	echoit mount -o compress-force=lzo ${TARGET} ${BNCHMNT}
fi

# Test for things being where we expect.
if [[ ! -e "${BASE_LINUX_SOURCES_SUBVOL}/MAINTAINERS" ]]; then
	echo "The root sources do not seem to be present!"
	echo "Exiting..."
	exit 1
fi

CMDS="${TIMEBIN} ${BTRFSBIN} wc shuf head git"
for i in $CMDS; do
	# command -v will return >0 when the $i is not found
	command -v $i >/dev/null || { echo "$i command not found."; exit 1; }
done

cd  ${BNCHMNT}

NUM_SNAPSHOTS=$(ls -d ${BSUBVOL}/linux-btrfs* | wc -l)
if (ls -d ${BSUBVOL}/linux-btrfs*); then
	echo "${NUM_SNAPSHOTS} previous snapshots found!"
else
	echo "No Snapshots found in $${BSUBVOL}"
	echo "Exiting..."
	exit 1
fi

# Pick a random snapshot
SRC_SNAPSHOT=$(ls -d ${BSUBVOL}/linux-btrfs*|shuf|head -1)
echo "Source snapshot: ${SRC_SNAPSHOT}"

${BTRFSBIN} subvolume snapshot "${SRC_SNAPSHOT}" "${BSUBVOL}/linux-btrfs-${TIMESLOT}"
cd "${BSUBVOL}/linux-btrfs-${TIMESLOT}"

# If the top manipulation is found, reset...
if (git branch | grep "btrfs-eater-3"); then
	echo "Snapshot at btrfs-eater-3, resetting..."
	git checkout master
	git branch -D btrfs-eater-1
	git branch -D btrfs-eater-2
	git branch -D btrfs-eater-3
fi

if (git branch | grep "btrfs-eater-2"); then
	echo "Setting Snapshot to btrfs-eater-3"
	# Checks out 2.6.36
	git checkout f6f94e2ab1b33f0082ac2
	git checkout -b btrfs-eater-3
	git pull ${BASE_LINUX_SOURCES_SUBVOL} linux-2.6.37.y >> /dev/null
elif (git branch | grep "btrfs-eater-1"); then
	echo "Setting Snapshot to btrfs-eater-2"
	# Checks out 2.6.35
	git checkout 9fe6206f400646a2322096b56
	git checkout -b btrfs-eater-2
	git pull ${BASE_LINUX_SOURCES_SUBVOL} linux-2.6.37.y >> /dev/null
else
	# checks out to 2.6.34
	echo "Setting Snapshot to btrfs-eater-1"
	git checkout e40152ee1e1c7a63f4777
	git checkout -b btrfs-eater-1
	git pull ${BASE_LINUX_SOURCES_SUBVOL} linux-2.6.37.y >> /dev/null
fi


# Display some general status information 
echo "Filesystem     Type   1K-blocks     Used Available Use% Mounted on"
df -T | grep ${BNCHMNT}

${BTRFSBIN} fi df ${BNCHMNT}

NUM_SNAPSHOTS=$(ls -d ${BSUBVOL}/linux-btrfs* | wc -l)

if [[ -e snapshot-count.orig ]]; then
        TCOUNT=$(cat snapshot-count.orig)
        echo "snapshot-count.orig found (${TCOUNT})."
	let "TCOUNT+=1"
	echo "${TCOUNT}" > snapshot-count.orig
else
	echo "1" > snapshot-count.orig
	echo "Creating new snapshot-count.orig file"
fi
