-- Use this script to add your database functions, for cases where the
-- functions depend on other objects being already created in the schema.

SET search_path TO :"nspace", :"apinspace", public;

CREATE OR REPLACE FUNCTION :"nspace".reset_api_secret() RETURNS VOID AS
$FUNC$
BEGIN
    UPDATE _api_secrets
    SET during = tsrange(lower(during), NOW()::TIMESTAMP, '[)')
    WHERE during @> NOW()::TIMESTAMP;

    INSERT INTO _api_secrets DEFAULT VALUES;
END
$FUNC$
LANGUAGE PLPGSQL
VOLATILE SECURITY DEFINER;