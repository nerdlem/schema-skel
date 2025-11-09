-- Use this script to add your database functions, for cases where the
-- functions depend on other objects being already created in the schema.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

-- Store the schema names in temporary configuration parameters and a temporary table
-- for easier use down the line.
SELECT set_config('app.temp.nspace', :'nspace', false) AS nspace,
       set_config('app.temp.apinspace', :'apinspace', false) AS apinspace,
       set_config('app.temp.cfgnspace', :'cfgnspace', false) AS cfgnspace
       INTO TEMPORARY TABLE __temp_params;

CREATE OR REPLACE FUNCTION :"nspace".reset_api_secret() RETURNS VOID AS
$FUNC$
BEGIN
    UPDATE _api_secrets
    SET during = tsrange(lower(during), NOW()::TIMESTAMP, '[)'),
        secret = '<DISABLED>'
    WHERE during @> NOW()::TIMESTAMP;

    INSERT INTO _api_secrets DEFAULT VALUES;
END
$FUNC$
LANGUAGE PLPGSQL
VOLATILE SECURITY DEFINER;

COMMENT ON FUNCTION :"nspace".reset_api_secret IS 'Phase out the prior API secret, generating a new one.';

CREATE OR REPLACE FUNCTION :"apinspace".login(username TEXT, password TEXT) RETURNS :"nspace".jwt_token AS
$FUNC$
DECLARE
  _result RECORD;
  result jwt_token;
BEGIN

  PERFORM postgrest_pre_config();

  SELECT u.password = crypt(login.password, u.password) AS match
       , COALESCE ( u.dbrole, 'api_anon' ) AS role
       , u.username AS username
  INTO _result
  FROM _api_users u
  WHERE u.during @> NOW()::TIMESTAMP
    AND u.username = login.username;

  IF _result.match THEN
    SELECT public.sign(
        json_build_object( 'role', _result.role,
                           'username', _result.username,
                           'issued', NOW()::TIMESTAMP,
                           'exp', EXTRACT(epoch FROM NOW())::INTEGER + s.token_duration ),
        current_setting('pgrst.jwt_secret')
    ) AS token
    INTO result
    FROM current_api_secret s
    ORDER BY 1 LIMIT 1;

    RETURN result;
  END IF;

  RAISE invalid_password
  USING MESSAGE = 'invalid credentials',
        HINT = FORMAT('check the username (%s) and password provided in the request', username);
END;
$FUNC$
LANGUAGE plpgsql
SET search_path TO :"nspace", public
SECURITY DEFINER;

DO $DO$
BEGIN
    FORMAT('-- Dynamically generated statement
    CREATE OR REPLACE FUNCTION "%1$s".postgrest_pre_config() RETURNS VOID AS
    $$
      SELECT
      set_config(''pgrst.jwt_secret'', ( SELECT secret FROM current_api_secret LIMIT 1), true)
    , set_config(''pgrst.db_schemas'', ''%2$s'', true)
    , set_config(''pgrst.db_pre_request'', ''%1$s.postgrest_post_auth'', true)
    , set_config(''pgrst.openapi_security_active'', ''true'', true);
    $$
    LANGUAGE SQL
    SET search_path TO "%1$s", public
    SECURITY DEFINER;
    ', current_setting('app.temp.nspace'), current_setting('app.temp.apinspace'));
END
$DO$;

CREATE OR REPLACE FUNCTION :"nspace".postgrest_post_auth() RETURNS VOID AS
$$
DECLARE
  request_signature TEXT = FORMAT( '%s:%s',
                                   current_setting('request.method', true),
                                   current_setting('request.path', true) );
  source_ip INET = (current_setting('request.headers', true)::jsonb->>'x-real-ip')::INET;
  jwt_username TEXT = current_setting('request.jwt.claims')::jsonb->>'username';
BEGIN

    IF jwt_username IS NULL THEN RETURN; END IF;

    PERFORM
    FROM _api_users u
    WHERE u.username = jwt_username
      AND u.during @> NOW()::TIMESTAMP
      AND request_signature ~ u.authorized_re
      AND ( u.authorized_subnets IS NULL
            OR EXISTS (
              SELECT TRUE
              FROM ( SELECT sn
                     FROM unnest( u.authorized_subnets ) sn
                     WHERE sn.sn >>= source_ip
              ) u
            )
          )
    LIMIT 1;

    IF NOT FOUND THEN
      RAISE invalid_password
      USING MESSAGE = 'not authorized',
            HINT = FORMAT( 'user %s is not authorized to execute request %s from IP %s',
                           jwt_username, request_signature, source_ip );

    END IF;

    RETURN;
END;
$$
LANGUAGE plpgsql
SET search_path TO :"nspace", public
VOLATILE
SECURITY DEFINER;

COMMENT ON FUNCTION :"nspace".postgrest_post_auth() IS
$$Perform request processing prior to execution.

This is a great place to enforce request restrictions or otherwise provide generalized processing such as
generating headers.

In this case, we use this opportunity to perform authorization checks.
$$;