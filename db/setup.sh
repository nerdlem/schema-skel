#!/usr/bin/env bash

set -e

PGNAMESPACE=${PGNAMESPACE:=skel}
PGAPINAMESPACE=${PGAPINAMESPACE:=api${PGNAMESPACE}}
PGCFGNAMESPACE=${PGCFGNAMESPACE:=cfg${PGNAMESPACE}}
SCHEMA_ERRATA_CSV=${SCHEMA_ERRATA_CSV:=/tmp/${PGNAMESPACE}-schema_errata.csv}

PSQL=${PSQL:=$(which psql)}
PSQL_CMD=${PSQL_CMD:=${PSQL} --set=nspace="${PGNAMESPACE}" --set=apinspace="${PGAPINAMESPACE}" --set=cfgnspace="${PGCFGNAMESPACE}"}

PGPROVE=${PGPROVE:=$(which pg_prove)}
PGPROVE_CMD=${PGPROVE_CMD:=${PGPROVE}  --set=nspace="${PGNAMESPACE}" --set=apinspace="${PGAPINAMESPACE}" --set=cfgnspace="${PGCFGNAMESPACE}"}
