-- Use this script to enable the database extensions that your database
-- application will require. Also conditionally generate any schemas or
-- namespaces that will be needed by your appllication.

-- Namespaces that will be used in this project. You can pass this namespace via
-- the environment.

CREATE SCHEMA IF NOT EXISTS :"nspace";
CREATE SCHEMA IF NOT EXISTS :"apinspace";
SET search_path TO :"nspace", public;

-- Frequent candidates include pgcrypto, pgjwt, etc.

-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us;
-- CREATE EXTENSION IF NOT EXISTS address_standardizer;
-- CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
-- CREATE EXTENSION IF NOT EXISTS hstore;
-- CREATE EXTENSION IF NOT EXISTS ip4r;
-- CREATE EXTENSION IF NOT EXISTS pg_hint_plan;
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- CREATE EXTENSION IF NOT EXISTS pgjwt;
CREATE EXTENSION IF NOT EXISTS pgtap;

