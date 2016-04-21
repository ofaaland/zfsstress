#!/bin/bash

BASEDIR=$(pushd $(dirname $0) >/dev/null; pwd; popd >/dev/null)

# use config if it exists
if [[ -f "${BASEDIR}/execute_test.config" ]]; then
	. "${BASEDIR}/execute_test.config"
fi

ZFSSTRESS="${BASEDIR}/runstress.sh"

if [[ ! -x ${ZFSSTRESS} ]]; then
	echo "ERROR: ${ZFSSTRESS} is not executable"
	exit 1
fi

if [[ ! -d "${ROOTDIR}" ]]; then
	${setup_dir} "${ROOTDIR}"
fi

if [[ ! -d "${LOGDIR}" ]]; then
	${setup_dir} "${LOGDIR}"
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
