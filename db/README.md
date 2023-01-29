# Database schema generation scripts

The `.ddl` files in this directory contains the DDL that defines the required objects in the database. The general idea is to split your database schema creation in sensible sections that can be applied in sequence by the `Makefile` rules -- take a look at that file to see the specific order in which they are invoked. The basic actions provided by these rules are also available as standalone shell scripts. This helps with deployments employing AWS Lambda, where GNU Make is unable to launch external programs due to its use of blocked system calls.

Of course, you're free to adapt this to your own style. In some cases a single `.ddl` file with all commands will do. In more complex scenarios, you might want to have subdirectories containing the DDL for large parts of your database schema.

In general terms, these `.ddl` files are meant to deploy your database schema to a plain, blank database.

## Makefile provisioning and AWS Lambda

At the time of this writing, the AWS Lambda environment imposes a series of security restrictions on the workloads it executes. One such restriction involves the use of _tracing syscalls_. GNU Make uses some of these calls internally to track the status of its subprocesses, which causes issues when attempting deployments via λ. These examples are migrating towards a shell-script based deployment strategy to simplify deployments in these types of environments.

For any new applications you should plan on invoking the following scripts instead of the corresponding `Makefile` targets.

| Script         | Replaces `make` target | Purpose |
| :------------- | :--------------------- | :------- |
| `./deploy.sh`  | `deploy`               | Deploys a pristine database schema _without_ any additional schema deltas. |
| `./deltas.sh`  | `deltas`               | Applies all pending deltas. |
| `./destroy.sh` | `destroy`              | Destroys the schema and its data using your provided scripts. |
| `./test.sh`    | `test`                 | Run database test suite with `pg_prove`. |

## Namespace support

The provided scripts create a single namespace to help keep the different components of a project logically separated. To set the desired namespace value you can use the environment variable `$PGNAMESPACE`. Note that this environment variable is folded into a `psql` variable `:nspace` that is expected to be used across the rest of the provisioning scripts.

The design assumes that there will be at least one namespace per application sharing the database.

By default, the scripts attempt a conditional namespace creation, as depicted below.

```sql
CREATE SCHEMA IF NOT EXISTS :"nspace";
```

Both the `Makefile` and supplied shell scripts default to `skel` as the namespace.

On destruction, the provided scripts do not attempt to destroy the namespace, as this simplifies overall database provisioning in some cases. Feel free to adjust to the specifics of your use case.

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
