-- Use this script to define custom database roles required by your
-- applications, as well as GRANTing privileges to them.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

CREATE ROLE _pgrest_authenticator LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER;
CREATE ROLE _pgrest_anon NOLOGIN;
CREATE ROLE _pgrest_user NOLOGIN;

ALTER ROLE _pgrest_authenticator SET statement_timeout TO '10s';
ALTER ROLE _pgrest_anon SET statement_timeout TO '1s';
ALTER ROLE _pgrest_user SET statement_timeout TO '1s';

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public, :"nspace", :"apinspace" FROM _pgrest_authenticator, _pgrest_user, _pgrest_anon CASCADE;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM _pgrest_authenticator, _pgrest_user, _pgrest_anon CASCADE;

GRANT USAGE ON SCHEMA :"nspace", :"apinspace", :"cfgnspace" TO _pgrest_authenticator;
GRANT SELECT ON :"nspace".current_api_secret, :"nspace"._api_users TO _pgrest_authenticator;
GRANT EXECUTE ON FUNCTION :"apinspace".login TO _pgrest_authenticator;
GRANT EXECUTE ON FUNCTION :"nspace".postgrest_post_auth TO _pgrest_authenticator;

GRANT USAGE ON SCHEMA :"apinspace", :"nspace" TO _pgrest_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA :"apinspace" TO _pgrest_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA :"apinspace" TO _pgrest_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA :"apinspace" TO _pgrest_user;
GRANT EXECUTE ON FUNCTION :"nspace".postgrest_post_auth TO _pgrest_user;

GRANT USAGE ON SCHEMA :"nspace" TO _pgrest_anon;
GRANT EXECUTE ON FUNCTION :"nspace".postgrest_post_auth TO _pgrest_anon;

CREATE ROLE api_master WITH LOGIN INHERIT PASSWORD 'ChangeAPIMasterPassword' IN ROLE _pgrest_authenticator;
CREATE ROLE api_user   WITH LOGIN INHERIT PASSWORD 'ChangeAPIUserPassword' IN ROLE _pgrest_user;
CREATE ROLE api_anon   WITH NOLOGIN INHERIT IN ROLE _pgrest_user;

GRANT api_anon TO _pgrest_authenticator;
