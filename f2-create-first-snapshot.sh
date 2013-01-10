#!/bin/bash

#
# f2-create-first-snapshot.sh
#
# Create the first snapshot for linux source snapshot testing.
#

BASEDIR="${0%/*}"
source "${BASEDIR}/common-include.sh"
TIMESLOT=$(date '+%Y%m%d-%H%M%S')

cat /proc/version
cat /proc/cmdline
echo "TIMESLOT is ${TIMESLOT}"

# if (cat /proc/cmdline | grep subvolid=268); then
#	echo "Sabayon XFCE Hardened x86_64"
# else
#	echo "Sabayon XFCE Baseline"
# fi

if (cat /proc/mounts | grep "${BNCHMNT}"); then
	echo "${BNCHMNT} mountpoint is mounted..."
else
	echo "Mount ${BNCHMNT} not found, attempting to mount..."

	echoit mount -o compress-force=lzo /dev/sda7 /mnt/benchmark
	# echoit mount -o compress-force=zlib /dev/sda7 /mnt/benchmark
	# echoit mount /dev/sda7 /mnt/benchmark
fi

# Test for things being where we expect.
if [[ ! -e "${BNCHMNT}/${BASE_LINUX_SOURCES_SUBVOL}/MAINTAINERS" ]]; then
	echo "The root sources do not seem to be present!"
	echo "Exiting..."
	exit 1
fi

if [[ ! -e ${TIMEBIN} ]]; then
	echo "Application ${TIMEBIN} not found (is it installed?)! Exiting!!!"
	exit 1
fi

cd  ${BNCHMNT}

${BTRFSBIN} subvolume snapshot \
	"${BNCHMNT}/${BASE_LINUX_SOURCES_SUBVOL}" \
	"${BNCHMNT}/${BSUBVOL}/linux-btrfs-${TIMESLOT}"


# Display some general status information 
df -T

${BTRFSBIN} fi df /mnt/benchmark/
