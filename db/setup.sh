#!/usr/bin/env bash

set -e

export PGDATABASE=${PGDATABASE:=${USER}}
export PGNAMESPACE=${PGNAMESPACE:=skel}
export PGAPINAMESPACE=${PGAPINAMESPACE:=api${PGNAMESPACE}}
export PGCFGNAMESPACE=${PGCFGNAMESPACE:=cfg${PGNAMESPACE}}
export SCHEMA_ERRATA_CSV=${SCHEMA_ERRATA_CSV:=/tmp/${PGNAMESPACE}-schema_errata.csv}

export PSQL=${PSQL:=$(which psql)}
export PSQL_CMD=${PSQL_CMD:=${PSQL} --set=nspace="${PGNAMESPACE}" --set=apinspace="${PGAPINAMESPACE}" --set=cfgnspace="${PGCFGNAMESPACE}"}

export PGPROVE=${PGPROVE:=$(which pg_prove)}
export PGPROVE_CMD=${PGPROVE_CMD:=${PGPROVE}  --set=nspace="${PGNAMESPACE}" --set=apinspace="${PGAPINAMESPACE}" --set=cfgnspace="${PGCFGNAMESPACE}"}
