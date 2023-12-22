#!/usr/bin/env bash

set -e
. ./setup.sh

echo -- Running database schema "${PGNAMESPACE}"

for ddl in prerequisites.ddl \
           types.ddl \
           functions.ddl \
           schema.ddl \
           schema-deltas.ddl \
           views.ddl \
           roles.ddl \
           post-functions.ddl \
           triggers.ddl \
           schema-deltas.sql \
           seed-data.sql \
           ;
do
    echo -- "  " "${ddl}"
    PSQLRC=psqlrc-quiet ${PSQL_CMD} -f "${ddl}"
done

exit 0

