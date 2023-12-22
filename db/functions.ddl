-- Use this script to add your database functions on which other objects
-- depend for provisioning.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

CREATE OR REPLACE FUNCTION :"nspace".random_password(n INTEGER DEFAULT 32) RETURNS TEXT AS
$$
BEGIN
    RETURN left(encode(gen_random_bytes(64), 'hex'), n);
END;
$$
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER;

COMMENT ON FUNCTION random_password(INTEGER) IS 'Output a randomly generated, hex password of the given length, defaults to 32 characters';