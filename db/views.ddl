-- Use this script to generate any VIEWs your application might need.

SET search_path TO :"nspace", :"apinspace", public;

CREATE OR REPLACE VIEW current_api_secret AS
SELECT secret
FROM :"nspace"._api_secrets WHERE during @> NOW()::TIMESTAMP;
