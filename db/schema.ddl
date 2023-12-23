-- Use this script to create tables for your database schema. You also might
-- want to use this script to add INDEXes, so that their definition lives closer
-- to the actual tables.

SET search_path TO :"nspace", :"apinspace", :"cfgnspace", public;

CREATE TABLE :"nspace"._inh_audit (
    created_ts TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by TEXT NOT NULL DEFAULT current_user
);

COMMENT ON TABLE :"nspace"._inh_audit IS 'This table provides columns to track addition of individual rows. The timestamp and database username is recorded for each row.';

CREATE TABLE :"nspace"._api_secrets (
    id             SERIAL NOT NULL PRIMARY KEY,
    secret         TEXT NOT NULL DEFAULT encode(gen_random_bytes(64), 'hex'),
    token_duration INTEGER NOT NULL DEFAULT 3600,
    during         TSRANGE NOT NULL DEFAULT tsrange(NOW()::timestamp, 'infinity', '[)'),
    EXCLUDE USING GIST (during WITH &&)
) INHERITS ( :"nspace"._inh_audit );

INSERT INTO :"nspace"._api_secrets DEFAULT VALUES;

-- The below exclusion constraint requires the btree_gist extension that
-- provides the required operator class for the = operator with TEXT

CREATE TABLE :"nspace"._api_users (
    id                  SERIAL NOT NULL PRIMARY KEY,
    username            TEXT NOT NULL,
    dbrole              TEXT,
    authorized_re       TEXT NOT NULL DEFAULT '.?',
    password            TEXT NOT NULL DEFAULT crypt(random_password(32), gen_salt('bf', 8)),
    during              TSRANGE NOT NULL DEFAULT tsrange(NOW()::timestamp, 'infinity', '[)'),
    EXCLUDE USING GIST (username WITH =, during WITH &&)
) INHERITS ( :"nspace"._inh_audit );
