-- Use this script to define PostgreSQL domains / types that your application
-- will require.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

-- Store the schema names in temporary configuration parameters and a temporary table
-- for easier use down the line.
SELECT set_config('app.temp.nspace', :'nspace', false) AS nspace,
       set_config('app.temp.apinspace', :'apinspace', false) AS apinspace,
       set_config('app.temp.cfgnspace', :'cfgnspace', false) AS cfgnspace
       INTO TEMPORARY TABLE __temp_params;

CREATE TYPE :"nspace".jwt_token AS (
  token text
);
