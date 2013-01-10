#!/bin/bash

#
# f4-delete-random-snapshot.sh
#
# delete a random snapshot snapshot for linux source snapshot testing.
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
if [[ ! -e "${BNCHMNT}/linux-stable/MAINTAINERS" ]]; then
	echo "The root sources do not seem to be present!"
	echo "Exiting..."
	exit 1
fi

CMDS="${TIMEBIN} ${BTRFSBIN} wc shuf head"
for i in $CMDS; do
	# command -v will return >0 when the $i is not found
	command -v $i >/dev/null || { echo "$i command not found."; exit 1; }
done

cd  ${BNCHMNT}

if (ls -d ${BSUBVOL}/linux-btrfs*); then
	echo "$(ls -d ${BSUBVOL}/linux-btrfs* | wc -l) previous snapshots found!"
else
	echo "No Snapshots found in ${BSUBVOL}"
	echo "Exiting..."
	exit 1
fi

# Pick a random snapshot
DEL_SNAPSHOT=$(ls -d ${BSUBVOL}/linux-btrfs*|shuf|head -1)
echo "Snapshot to remove: ${DEL_SNAPSHOT}"

${BTRFSBIN} subvolume delete "${DEL_SNAPSHOT}"


# Display some general status information 
df -T ${BNCHMNT}

${BTRFSBIN} fi df ${BNCHMNT}
