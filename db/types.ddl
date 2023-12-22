-- Use this script to define PostgreSQL domains / types that your application
-- will require.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

CREATE TYPE :"nspace".jwt_token AS (
  token text
);
