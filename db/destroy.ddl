-- This script should remove all objects created by the provisioning process.

-- It might be a good idea to employ a transaction and verifying that this is
-- not being run on sensitive instances, such as production.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

SET SESSION app.ephemeral_dbs = 'dev,qa,lem';

BEGIN;

SELECT set_config('app.temp.nspace', :'nspace', false) AS nspace,
       set_config('app.temp.apinspace', :'apinspace', false) AS apinspace,
       set_config('app.temp.cfgnspace', :'cfgnspace', false) AS cfgnspace
       INTO TEMPORARY TABLE __temp_params;

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

DO $revokes$
DECLARE
    api_roles text[] := ARRAY['api_anon', 'api_master', 'api_user'];
    pgrest_roles text[] := ARRAY['_pgrest_anon', '_pgrest_authenticator', '_pgrest_user'];
    schemas text[] := ARRAY[current_setting('app.temp.nspace'), 
                            current_setting('app.temp.apinspace'),
                            current_setting('app.temp.cfgnspace'), 
                            'public'];
    role text;
    schema text;
BEGIN
    -- Revoke schema privileges
    FOREACH schema IN ARRAY schemas LOOP
        -- API roles
        FOREACH role IN ARRAY api_roles LOOP
            BEGIN
                EXECUTE format('REVOKE ALL ON SCHEMA %I FROM %I', schema, role);
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'Error revoking schema privileges from API role: schema=%, role=%, detail=%', schema, role, SQLERRM;
            END;
        END LOOP;
        
        -- PGREST roles - more extensive privileges
        FOREACH role IN ARRAY pgrest_roles LOOP
            BEGIN
                -- Schema access
                EXECUTE format('REVOKE ALL ON SCHEMA %I FROM %I', schema, role);
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'Error revoking schema ALL privileges: schema=%, role=%, detail=%', schema, role, SQLERRM;
            END;

            BEGIN
                EXECUTE format('REVOKE USAGE ON SCHEMA %I FROM %I', schema, role);
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'Error revoking schema USAGE privileges: schema=%, role=%, detail=%', schema, role, SQLERRM;
            END;

            BEGIN
                -- Table privileges
                EXECUTE format('REVOKE ALL ON ALL TABLES IN SCHEMA %I FROM %I', schema, role);
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'Error revoking table privileges: schema=%, role=%, detail=%', schema, role, SQLERRM;
            END;
            
            -- Function privileges for non-public schemas
            IF schema != 'public' THEN
                BEGIN
                    EXECUTE format('REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA %I FROM %I', schema, role);
                EXCEPTION WHEN OTHERS THEN
                    RAISE NOTICE 'Error revoking function privileges: schema=%, role=%, detail=%', schema, role, SQLERRM;
                END;
            END IF;
            
            -- Sequence privileges for non-public schemas
            IF schema != 'public' THEN
                BEGIN
                    EXECUTE format('REVOKE USAGE ON ALL SEQUENCES IN SCHEMA %I FROM %I', schema, role);
                EXCEPTION WHEN OTHERS THEN
                    RAISE NOTICE 'Error revoking sequence privileges: schema=%, role=%, detail=%', schema, role, SQLERRM;
                END;
            END IF;
        END LOOP;
    END LOOP;
END $revokes$;

DO $$
DECLARE
    role_name text;
BEGIN
    -- First, drop all objects owned by these roles
    FOR role_name IN SELECT rolname 
                     FROM pg_catalog.pg_roles 
                     WHERE rolname IN ('api_anon', 'api_master', 'api_user', 
                                     '_pgrest_anon', '_pgrest_authenticator', '_pgrest_user')
    LOOP
        BEGIN
            EXECUTE format('DROP OWNED BY %I CASCADE', role_name);
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error dropping objects owned by %: %', role_name, SQLERRM;
        END;
        
        BEGIN
            EXECUTE format('DROP ROLE IF EXISTS %I', role_name);
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error dropping role %: %', role_name, SQLERRM;
        END;
    END LOOP;
END $$;

DO $$
DECLARE
    schema_name text;
BEGIN
    FOR schema_name IN SELECT unnest(ARRAY[
        current_setting('app.temp.nspace'),
        current_setting('app.temp.apinspace'),
        current_setting('app.temp.cfgnspace')
    ])
    LOOP
        BEGIN
            EXECUTE format('DROP SCHEMA IF EXISTS %I CASCADE', schema_name);
            RAISE NOTICE 'Successfully dropped schema: %', schema_name;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error dropping schema %: %', schema_name, SQLERRM;
        END;
    END LOOP;
END $$;

COMMIT;

