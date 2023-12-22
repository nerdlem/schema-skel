-- This script should remove all objects created by the provisioning process.

-- It might be a good idea to employ a transaction and verifying that this is
-- not being run on sensitive instances, such as production.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

SET SESSION app.ephemeral_dbs = 'dev,qa,lem';

BEGIN;

DO $$
BEGIN
  PERFORM TRUE
  WHERE NOT string_to_array(current_setting('app.ephemeral_dbs'), ',')
            @> ARRAY[CURRENT_DATABASE()::TEXT];
  IF FOUND THEN
    RAISE EXCEPTION
    USING message = 'cannot destroy this database',
          hint = FORMAT('only database %s can be destroyed',
                        current_setting('app.ephemeral_dbs'));
  END IF;
END;
$$
LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS :"cfgnspace".postgrest_login(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS :"cfgnspace".random_password(INT) CASCADE;
DROP FUNCTION IF EXISTS :"cfgnspace".reset_api_secret() CASCADE;
DROP FUNCTION IF EXISTS :"nspace".trg_crypt_password() CASCADE;

DROP VIEW IF EXISTS :"cfgnspace".current_api_secret CASCADE;

DROP TABLE IF EXISTS :"nspace".schema_errata;
DROP TABLE IF EXISTS :"nspace".example;

DROP SCHEMA :"nspace" CASCADE;
DROP SCHEMA :"apinspace" CASCADE;
DROP SCHEMA :"cfgnspace" CASCADE;

DROP ROLE IF EXISTS api_anon;
DROP ROLE IF EXISTS api_master;
DROP ROLE IF EXISTS api_user;

DROP ROLE IF EXISTS _pgrest_anon;
DROP ROLE IF EXISTS _pgrest_authenticator;
DROP ROLE IF EXISTS _pgrest_user;

COMMIT;
