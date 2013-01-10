#!/bin/bash

#
# snapshot-loop.sh
#
# Iterate Snapshot creation and deletion.
#
# The loop can be exited in an orderly manner by pressing any of QqXx.
#

BASEDIR="${0%/*}"
source "${BASEDIR}/common-include.sh"

TIMESLOT=$(date '+%Y%m%d-%H%M%S')

CMDS="${TIMEBIN} ${BTRFSBIN} bc wc gawk stty"
for i in $CMDS; do
	# command -v will return >0 when the $i is not found
	command -v $i >/dev/null || { echo "$i command not found."; exit 1; }
done

ITER=0
DONE=0

while [ "${DONE}" == "0" ]; do
	let "ITER+=1"
	echo "Current Iteration: ${ITER}"
	${BASEDIR}/f3-manipulate-snapshot.sh

	# NUM_SNAPSHOTS=$(ls -d ${BNCHMNT}/${BSUBVOL}/linux-btrfs* | wc -l)
	# if (( ${NUM_SNAPSHOTS} > 53 )); then
	#	${BASEDIR}/f4-delete-random-snapshot.sh
	# fi

	# Start deleting some snapshots when the volume is > 75% full
	# NOTE: Depends on the bc command.
	AVAIL_SPACE=$(df -T | grep "${BNCHMNT}" | gawk '{print $5}')
	TOTAL_SPACE=$(df -T | grep "${BNCHMNT}" | gawk '{print $3}')
	B_SA_FRACTION=$(echo "scale=3; (${AVAIL_SPACE} / ${TOTAL_SPACE}) < 0.25" | bc)
	if (( ${B_SA_FRACTION} > 0 )); then
		${BASEDIR}/f4-delete-random-snapshot.sh
		${BASEDIR}/f4-delete-random-snapshot.sh
		${BASEDIR}/f4-delete-random-snapshot.sh
	fi

	if [ -t 0 ]; then stty -echo -icanon time 0 min 0; fi

	KEYPRESS=''
	EXITKEYS="qQxX"
	read KEYPRESS

	if [ -t 0 ]; then stty sane; fi

	if [ "x${KEYPRESS}" != "x" ]; then
		if [ $EXITKEYS != "${EXITKEYS/${KEYPRESS}/}" ]; then
			echo "Exiting on Iteration ${ITER}..."
			DONE="1"
		else
			echo "The ${KEYPRESS} key was pressed (Iteration: ${ITER}), wait 5 seconds..."
			sleep 5
		fi
	fi
done
