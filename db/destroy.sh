#!/usr/bin/env bash

set -e
. ./setup.sh

PGNAMESPACE=${PGNAMESPACE:=skel}
PGAPINAMESPACE=${PGAPINAMESPACE:=api${PGNAMESPACE}}
PSQL=${PSQL:=psql}
PSQL_CMD=${PSQL_CMD:=${PSQL} --set=nspace="${PGNAMESPACE}" --set=apinspace="${PGAPINAMESPACE}"}

echo -- Destroying schema on namespace "${PGNAMESPACE}"

for ddl in destroy.ddl \
           ;
do
    echo -- "  " "${ddl}"
    PSQLRC=psqlrc-quiet ${PSQL_CMD} -f "${ddl}"
done

exit 0

