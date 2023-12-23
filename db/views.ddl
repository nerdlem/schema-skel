-- Use this script to generate any VIEWs your application might need.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

CREATE OR REPLACE VIEW :"nspace".current_api_secret AS
SELECT secret, token_duration
FROM :"nspace"._api_secrets WHERE during @> NOW()::TIMESTAMP;

CREATE OR REPLACE VIEW :"apinspace".ping AS
SELECT TRUE AS alive,
       'Database connection is established' AS message,
       NOW()::TIMESTAMP AS ts,
       current_setting('request.jwt.claims')::json->>'username' AS username;

COMMENT ON VIEW :"apinspace".ping IS 'Provide a simple means to confirm that the underlying database connection is healthy.';

COMMENT ON COLUMN :"apinspace".ping.alive IS 'A true value is expected for live connections.';
COMMENT ON COLUMN :"apinspace".ping.message IS 'Human-readable informational message about the connection state.';
COMMENT ON COLUMN :"apinspace".ping.ts IS 'Server-side timestamp of the request, allows caller to troubleshoot caching issues.';
COMMENT ON COLUMN :"apinspace".ping.username IS 'If authenticated, the username contained in the JWT token.';