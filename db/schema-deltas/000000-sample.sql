-- This is an example of various techniques to write a database delta.

-- All schema delta files need to run in transactions. Usually a single
-- transaction is used to wrap all required changes, ensuring atomic execution.

BEGIN;

-- By inserting the delta name into the schema_errata table, the system can
-- automatically keep track of which delta files have been already applied.

INSERT INTO schema_errata ( delta )
VALUES ( '000000-sample' );

-- The statements in this delta will tipically include definition of VIEWs,
-- FUNCTIONs and other objects. Sometimes, operations that will involve changes
-- to the data such as type changes will be needed. In these cases you might
-- want to cause this script to output instructions to the user.

-- Keep in mind that this script will be run using the psql tool against the
-- PostgreSQL database being updated. This might very well be a production
-- database, so write your schema delta scripts accordingly.

-- The statements below are designed to always cause an error that would abort
-- this delta script, allowing for testing of the Makefile based mechanism.
-- Steps have been taken to prevent this error from showing up in this case.
-- Only trully abnormal or unexpected errors should show up during a schema
-- delta application, so please use your best judgement for your particular use
-- case.

\set ECHO none
SET client_min_messages TO PANIC;
SELECT 1/0 AS "000000-sample delta application, disregard";

COMMIT;
