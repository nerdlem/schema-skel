#!/usr/bin/env bash

set -e
. ./setup.sh

function produce_deltas() {
    if [ -s "${SCHEMA_ERRATA_CSV}" ]
    then
        find ./schema-deltas -type f -name '*.sql'                            |\
	        grep --invert-match --fixed-strings --file "${SCHEMA_ERRATA_CSV}"
    else
        find ./schema-deltas -type f -name '*.sql'
    fi
}

echo -- Deploying pending schema-deltas on namespace "${PGNAMESPACE}"

[ -f "${SCHEMA_ERRATA_CSV}" ] && rm -f "${SCHEMA_ERRATA_CSV}"

PSQLRC=psql-quiet ${PSQL_CMD} \
    -c "\COPY (SELECT delta FROM ${PGNAMESPACE}.schema_errata) TO '${SCHEMA_ERRATA_CSV}' WITH CSV;" 2>&1 \
    | ( egrep --no-messages --invert-match '^COPY 0$' || true )
[ -s "${SCHEMA_ERRATA_CSV}" ] && (echo >> "${SCHEMA_ERRATA_CSV}")

produce_deltas       |\
    sort             |\
    while read delta
    do 
       echo -- "  " Applying ${delta}...
       PSQLRC=psqlrc-quiet ${PSQL_CMD} -f "$delta"
    done

[ -f "${SCHEMA_ERRATA_CSV}" ] && rm -f "${SCHEMA_ERRATA_CSV}"

exit 0

