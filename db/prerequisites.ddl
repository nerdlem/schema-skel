-- Use this script to enable the database extensions that your database
-- application will require. Also conditionally generate any schemas or
-- namespaces that will be needed by your appllication.

-- Namespaces that will be used in this project. You can pass this namespace via
-- the environment.

CREATE SCHEMA IF NOT EXISTS :"nspace";
CREATE SCHEMA IF NOT EXISTS :"apinspace";
CREATE SCHEMA IF NOT EXISTS :"cfgnspace";

COMMENT ON SCHEMA :"apinspace" IS
$$A skeleton PostgREST API

This is a generic API description for your API. You might want to change this to better reflect what this API is about.
$$;


SET search_path TO :"nspace", public;

-- Frequent candidates include pgcrypto, pgjwt, etc.

-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
-- CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us WITH SCHEMA public;
-- CREATE EXTENSION IF NOT EXISTS address_standardizer WITH SCHEMA public;
-- CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;
-- CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;
-- CREATE EXTENSION IF NOT EXISTS ip4r WITH SCHEMA public;
-- CREATE EXTENSION IF NOT EXISTS pg_hint_plan WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
-- CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA public;

