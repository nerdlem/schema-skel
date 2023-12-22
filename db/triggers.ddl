-- Use this script to define TRIGGERs

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

CREATE OR REPLACE FUNCTION :"nspace".trg_crypt_password() RETURNS TRIGGER AS
$FUNC$
BEGIN
    IF NEW.password ~ '^\$[^$]+\$.+'
    THEN
        RETURN NEW;
    END IF;

    IF length(NEW.password) < 8
    THEN
        RAISE EXCEPTION
        USING MESSAGE = 'password too short', 
              HINT = 'please provide a longer password string',
              ERRCODE = 'invalid_parameter_value';
    END IF;

    NEW.password = crypt(NEW.password, gen_salt('bf', 8));
    RETURN NEW;
END;
$FUNC$
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER;

COMMENT ON FUNCTION :"nspace".trg_crypt_password() IS 'Automatically encrypt clear text passwords.';

CREATE TRIGGER crypt_password BEFORE INSERT OR UPDATE OF password 
ON :"nspace"._api_users
FOR EACH ROW EXECUTE FUNCTION :"nspace".trg_crypt_password();