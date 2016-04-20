#!/bin/bash

BASEDIR=$(pushd $(dirname $0) >/dev/null; pwd; popd >/dev/null)

#############
#CONFIGURATION
#############
export LOGDIR="/p/ldne/faaland1/zfsstress-logs"
export MOUNTPOINT="/p/ldne"
export ROOTDIR="${MOUNTPOINT}/faaland1/zfsstress"
TEST_ZFSSTRESS_RUNTIME=30
#############

ZFSSTRESS="${BASEDIR}/runstress.sh"

if [[ ! -x ${ZFSSTRESS} ]]; then
	echo "ERROR: ${ZFSSTRESS} is not executable"
	exit 1
fi

if [[ ! -d "${ROOTDIR}" ]]; then
	mkdir -p "${ROOTDIR}"
	if [[ "$?" -ne 0 ]]; then
		echo "ERROR: mkdir ${ROOTDIR} (ROOTDIR) failed: $?"
		exit 2
	fi
fi

if [[ ! -d "${LOGDIR}" ]]; then
	mkdir -p "${LOGDIR}"
	if [[ "$?" -ne 0 ]]; then
		echo "ERROR: mkdir ${LOGDIR} (LOGDIR) failed: $?"
		exit 3
	fi
fi

echo "running ${ZFSSTRESS} with:"
echo "  LOGDIR=${LOGDIR}"
echo "  MOUNTPOINT=${MOUNTPOINT}"
echo "  ROOTDIR=${ROOTDIR}"
echo "  TEST_ZFSSTRESS_RUNTIME=${TEST_ZFSSTRESS_RUNTIME}"

$ZFSSTRESS $TEST_ZFSSTRESS_OPTIONS $TEST_ZFSSTRESS_RUNTIME &
CHILD=$!
wait $CHILD
RESULT=$?

# Briefly delay to give any processes which are still exiting a chance to
# close any resources in the mount point so it can be cleanly unmounted.
sleep 5

if [[ $RESULT -eq 0 ]]; then
	echo "TEST PASSED"
else
	echo "TEST FAILED"
fi

exit $RESULT
