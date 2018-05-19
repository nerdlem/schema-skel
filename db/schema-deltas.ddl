-- This script is responsible for creating the schema_errata database table, to
-- keep track of the deltas that have been applied to this database schema.

CREATE TABLE schema_errata (
  delta TEXT NOT NULL PRIMARY KEY
);

COMMENT ON TABLE schema_errata IS
'Keep track of deltas applied to the database schema'
;

COMMENT ON COLUMN schema_errata.delta IS '
Unique tag identifying a particular change set applied to this database schema.
';
