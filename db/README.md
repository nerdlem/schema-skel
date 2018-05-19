# Database schema generation scripts

The `.ddl` files in this directory contains the DDL that defines the required objects in the database. The general idea is to split your database schema creation in sensible sections that can be applied in sequence by the `Makefile` rules -- take a look at that file to see the specific order in which they are invoked.

Of course, you're free to adapt this to your own style. In some cases a single `.ddl` file with all commands will do. In more complex scenarios, you might want to have subdirectories containing the DDL for large parts of your database schema.

In general terms, these `.ddl` files are meant to deploy your database schema to a plain, blank database.

## Configuring database coordinates

Scripts are executed via the `psql` tool, so any of the methods supported by that tool work for deployment. See the [psql Environment section](https://www.postgresql.org/docs/9.6/static/app-psql.html#APP-PSQL-ENVIRONMENT) for more information on the variables to use to point your deployment as desired. Specially the `PGDATABASE`, `PGHOST`, `PGPORT` and `PGUSER` variables.

An easy way to deploy a database could be as follows. In this example, `.pgpass` is used to supply the credentials automatically.

    PGHOST=my.db.host PGUSER=production_user make deploy

## Updating other database instances

Other database instances such as QA and Production will normally operate without the most recent _deltas_. As the time to deploy those _deltas_ come, it can be as simple as doing this.

    PGHOST=my.db.host PGUSER=production_user make deltas

## Destroying database schemas

The `destroy` target can be dangerous when working against a production instance. To help in preventing expensive errors, the shipped `destroy.ddl` includes a simple safeguard preventing harm to unknown databases.

> Make sure to edit your `destroy.ddl` file to match your environment. You should never be able to execute the `destroy` target against production!

The example below shows what happens when you try to `make destroy` the production database, by mistake.

    $ PGHOST=my.prod.database make destroy
    ( cd db; PSQLRC=psqlrc-test make destroy )
    psql -f destroy.ddl
    psql:destroy.ddl:23: ERROR:  cannot destroy this database
    HINT:  only database dev,qa can be destroyed
       ⋮
    psql:destroy.ddl:25: ERROR:  current transaction is aborted, commands ignored until end of transaction block
    psql:destroy.ddl:25: STATEMENT:  DROP TABLE IF EXISTS schema_errata;
    rm -f schema_errata.csv

You will need to tweak the definition of `app.ephemeral_dbs` to include the databases that you wish to be able to `destroy`.
