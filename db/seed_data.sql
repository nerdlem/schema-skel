-- This script is ment to insert the bootstrap data that your application
-- requires. Things such as detail tables used by foreign keys or other
-- bootstrap data can be added here.

-- This script is run at the end of the provisioning cycle, so all elements of
-- the database schema are in place.

-- One of the important tasks is to populate the schema_errata table to note the
-- schema deltas that can be considered as "applied" when the DDL scripts are
-- used to provision a new database.

INSERT INTO schema_errata ( delta )
VALUES ( '000000-sample' );
