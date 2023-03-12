-- Use this script to create tables for your database schema. You also might
-- want to use this script to add INDEXes, so that their definition lives closer
-- to the actual tables.

SET search_path TO :"nspace", :"apinspace", public;

CREATE TABLE :"nspace"._inh_audit (
    created_ts TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by TEXT NOT NULL DEFAULT current_user
);

COMMENT ON TABLE :"nspace"._inh_audit IS 'This table provides columns to track addition of individual rows. The timestamp and database username is recorded for each row.';
