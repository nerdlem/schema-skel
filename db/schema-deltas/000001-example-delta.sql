BEGIN;

INSERT INTO schema_errata ( delta )
VALUES ( '000001-example-delta' );

CREATE TABLE example (
  key SERIAL NOT NULL PRIMARY KEY,
  value TEXT
);

-- To merge this delta to the base provisioning scripts:
--
-- * Add the CREATE TABLE to your schema.ddl
-- * Add the INSERT to your seed_data.sql script
-- * Add "DROP TABLE example;" to your destroy.ddl

COMMIT;
