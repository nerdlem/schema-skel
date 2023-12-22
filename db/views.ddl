-- Use this script to generate any VIEWs your application might need.

SET search_path TO :"nspace", :"apinspace", public;

CREATE OR REPLACE VIEW :"nspace".current_api_secret AS
SELECT secret
FROM :"nspace"._api_secrets WHERE during @> NOW()::TIMESTAMP;

CREATE OR REPLACE VIEW :"apinspace".ping AS
SELECT TRUE AS alive,
       'Database connection is established' AS message,
       NOW()::TIMESTAMP AS ts;

COMMENT ON VIEW :"apinspace".ping IS 'Provide a simple means to confirm that the underlying database connection is healthy.';
