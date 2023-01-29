-- This script is responsible for creating the schema_errata database table, to
-- keep track of the deltas that have been applied to this database schema.

SET search_path TO :"nspace", public;

CREATE TABLE :"nspace".schema_errata (
  delta TEXT NOT NULL PRIMARY KEY
);

COMMENT ON TABLE :"nspace".schema_errata IS
'Keep track of deltas applied to the database schema'
;

COMMENT ON COLUMN :"nspace".schema_errata.delta IS '
Unique tag identifying a particular change set applied to this database schema.
';
