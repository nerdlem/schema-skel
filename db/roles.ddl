-- Use this script to define custom database roles required by your
-- applications, as well as GRANTing privileges to them.

SET search_path TO :"nspace", :"apinspace", public;

CREATE ROLE _pgrest_master;
CREATE ROLE _pgrest_user;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public, :"nspace", :"apinspace" FROM _pgrest_master, _pgrest_user CASCADE;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM _pgrest_master, _pgrest_user CASCADE;

GRANT USAGE ON SCHEMA :"nspace", :"apinspace" TO _pgrest_master;
GRANT SELECT ON :"nspace".current_api_secret, :"nspace"._api_users TO _pgrest_master;

GRANT USAGE ON SCHEMA :"apinspace" TO _pgrest_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA :"apinspace" TO _pgrest_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA :"apinspace" TO _pgrest_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA :"apinspace" TO _pgrest_user;

CREATE ROLE api_master WITH LOGIN INHERIT PASSWORD 'ChangeAPIMasterPassword' IN ROLE _pgrest_master;
CREATE ROLE api_user   WITH LOGIN INHERIT PASSWORD 'ChangeAPIUserPassword' IN ROLE _pgrest_user;