-- One of the important tasks is to populate the schema_errata table to note the
-- schema deltas that can be considered as "applied" when the DDL scripts are
-- used to provision a new database.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

-- INSERT INTO :"nspace".schema_errata ( delta )
-- VALUES ( '000000-example-schema-delta' );
