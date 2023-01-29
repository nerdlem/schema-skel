#!/usr/bin/env bash

set -e

PGNAMESPACE=${PGNAMESPACE:=skel}
SCHEMA_ERRATA_CSV=${SCHEMA_ERRATA_CSV:=/tmp/${PGNAMESPACE}-schema_errata.csv}

PSQL=${PSQL:=$(which psql)}
PSQL_CMD=${PSQL_CMD:=${PSQL} --set=nspace="${PGNAMESPACE}"}

PGPROVE=${PGPROVE:=$(which pg_prove)}
PGPROVE_CMD=${PGPROVE_CMD:=${PGPROVE}  --set=nspace="${PGNAMESPACE}"}
