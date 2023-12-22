-- Use this script to add your database functions, for cases where the
-- functions depend on other objects being already created in the schema.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

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

CREATE OR REPLACE FUNCTION :"cfgnspace".postgrest_login(_username TEXT, _password TEXT) RETURNS :"nspace".jwt_token AS
$FUNC$
DECLARE
  _result RECORD;
  result jwt_token;
BEGIN
  SELECT u.password = crypt(_password, u.password) AS match
       , COALESCE ( u.dbrole, 'api_user' ) AS role
  INTO _result
  FROM _api_users u
  WHERE u.during @> NOW()::TIMESTAMP
    AND u.username = _username;

  IF _result.match THEN
    SELECT public.sign(
        json_build_object( 'role', _result.role,
                            'exp', s.token_duration ),
        current_setting('pgrst.jwt_secret')
    ) AS token
    INTO result
    FROM current_api_secret s
    ORDER BY 1 LIMIT 1;

    RETURN result;
  END IF;

  RAISE invalid_password
  USING MESSAGE = 'invalid credentials',
        HINT = 'check the username and password provided in the request';
END;
$FUNC$
LANGUAGE plpgsql
SET search_path TO :"nspace", public
SECURITY DEFINER;

CREATE OR REPLACE FUNCTION :"nspace".postgrest_pre_config() RETURNS VOID AS
$$
    SELECT
      set_config('pgrst.jwt_secret', ( SELECT secret FROM current_api_secret LIMIT 1), true)
    , set_config('pgrst.db_schemas', 'apiskel', true)
--     , set_config('pgrst.db_pre_request', 'postgrest_post_auth', true)
    ;
$$
LANGUAGE SQL
SET search_path TO :"nspace", public;

CREATE OR REPLACE FUNCTION :"nspace".postgrest_post_auth() RETURNS VOID AS
$$
BEGIN
    RAISE NOTICE 'Executing postgrest_post_auth()';
    RETURN;
END;
$$
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER;