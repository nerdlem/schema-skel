#!/usr/bin/env bash

# The test target is meant to initiate a test suite based in pg_prove. See
# https://pgtap.org/

set -e
. ./setup.sh

if [ \! -x "${PGPROVE}" ]
then
    echo pg_prove is required to run database tests. Please install somewhere in the PATH
    exit 1
fi

# Since pg_prove invokes psql under the hood, the environment variables under
# the hood will work transparently, so no need to prime with command line flags.

${PGPROVE_CMD} ${PGPROVE_OPTS} --recurse ./t

exit 0

