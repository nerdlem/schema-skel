# Schema-skel, a database application skeleton

This is a baseline example that should be useful to start projects involving a relational database schema. For this particular case, a PostgreSQL database is assumed. Other database engines can be supported by making the relevant changes in the enclosed `Makefile`.

This skeleton is language agnostic as it only concerns with deploying a static database schema. In particular, this skeleton has been used without changes to support projects written in Perl and Go.

To start your project, simply clone this and start adding your database / programming code.

See [this article](https://lem.click/post/handling-database-schema-changes/) for a detailed discussion on how to channel your database changes through deltas.

The first versions of this skeleton were based in GNU Make. While this can still be used, I am gravitating towards a [script based deployment](https://lem.click/post/database-schema-shell/) for various reasons explained in the post.

The accompanying `db/README.md` file provides a more detailed discussion
about this repo.

## Dependencies and required extensions

Support for PostgREST introduces a dependency on
[pgjwt](https://github.com/michelp/pgjwt), btree_gist and pgcrypto. Please
ensure these extensions are availablein your environment.

Testing requires the pgtap extension as well as the `pg_prove` command line utility.

## Support for PostgREST

Roles, users and a few tables are provided to assist with deployments that
plan to use PostgREST for API provisioning. Base functions to control
configuration, store JWT secrets and authenticate users are provided.

The provided implementation is sufficient for you to add your views, tables
and functions that will then be automatically be available via the PostgREST
generated API.

## Namespaces

This schema sckeleton has been augmented so as to create two namespaces
(`SCHEMA` in PostgreSQL parlance). This is meant to assist with the use of the
[PostgREST](https://postgrest.org/) tool.

## Docker support

This distribution includes a simplistic Docker-based deployment helper that
will launch PostgREST and Redoc, pointing at your local database. This should
help get you started for your own deployments.
