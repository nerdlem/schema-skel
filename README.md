# Schema-skel, a database application skeleton

This is a baseline example that should be useful to start projects involving a relational database schema. For this particular case, a PostgreSQL database is assumed. Other database engines can be supported by making the relevant changes in the enclosed `Makefile`.

This skeleton is language agnostic as it only concerns with deploying a static database schema. In particular, this skeleton has been used without changes to support projects written in Perl and Go.

To start your project, simply clone this and start adding your database / programming code.

You might want to install the `pgtap` PostgreSQL extension and the `pg_prove` tool to get a working installation that is able to test itself.
