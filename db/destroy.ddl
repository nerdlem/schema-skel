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
DROP FUNCTION IF EXISTS :"apinspace".login(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS :"cfgnspace".random_password(INT) CASCADE;
DROP FUNCTION IF EXISTS :"cfgnspace".reset_api_secret() CASCADE;
DROP FUNCTION IF EXISTS :"nspace".trg_crypt_password() CASCADE;

DROP VIEW IF EXISTS :"cfgnspace".current_api_secret CASCADE;

DROP TABLE IF EXISTS :"nspace".schema_errata;
DROP TABLE IF EXISTS :"nspace".example;

DROP TABLE IF EXISTS :"nspace"._inh_audit CASCADE;

REVOKE ALL ON SCHEMA :"nspace" FROM api_anon, api_master, api_user;
REVOKE ALL ON SCHEMA :"apinspace" FROM api_anon, api_master, api_user;
REVOKE ALL ON SCHEMA :"cfgnspace" FROM api_anon, api_master, api_user;
REVOKE ALL ON SCHEMA public FROM api_anon, api_master, api_user;

DROP ROLE IF EXISTS api_anon;
DROP ROLE IF EXISTS api_master;
DROP ROLE IF EXISTS api_user;

REVOKE ALL ON SCHEMA :"nspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE ALL ON SCHEMA :"apinspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE ALL ON SCHEMA :"cfgnspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE ALL ON SCHEMA public FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA :"nspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user; 
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA :"apinspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;  
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA :"cfgnspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE ALL ON ALL TABLES IN SCHEMA :"nspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE ALL ON ALL TABLES IN SCHEMA :"apinspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE ALL ON ALL TABLES IN SCHEMA :"cfgnspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;

REVOKE USAGE ON ALL SEQUENCES IN SCHEMA :"apinspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE USAGE ON ALL SEQUENCES IN SCHEMA :"nspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE USAGE ON ALL SEQUENCES IN SCHEMA :"cfgnspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE USAGE ON SCHEMA :"nspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE USAGE ON SCHEMA :"apinspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;
REVOKE USAGE ON SCHEMA :"cfgnspace" FROM _pgrest_anon, _pgrest_authenticator, _pgrest_user;

DROP ROLE IF EXISTS _pgrest_anon;
DROP ROLE IF EXISTS _pgrest_authenticator;
DROP ROLE IF EXISTS _pgrest_user;

DROP SCHEMA :"nspace" CASCADE;
DROP SCHEMA :"apinspace" CASCADE;
DROP SCHEMA :"cfgnspace" CASCADE;

COMMIT;
