# Database schema deltas

This directory holds `.sql` files that are to be applied to the database in lexicographical order to ease changes to the different environments you might have. The overall structure of each database schema delta (_delta_ for short) is as follows:

```sql
BEGIN;

INSERT INTO schema_errata ( delta )
VALUES ( 'name of the schema delta file' );

⋮
-- more interesting SQL commands to change the Database
⋮

COMMIT;
```

This ensures that deltas can be run only once. The database-related `Makefile` includes the target `deltas` that will automatically attempt to apply all pending deltas, again in lexicographical order.

Deltas should be written to ensure no exceptions are thrown. This might very well be impractical in some cases, so an alternate mechanism has been defined, involving a `Makefile` present in this directory.

This mechanism provides for schema delta authors to implement more complex provisioning tasks, involving perhaps scripts written in other languages that could run automatically as part of the schema update. All resources employed by these deltas should be placed inside a directory named after the original `.sql` file.

> It's vital for schema delta authors to ensure that deltas can only be applied once to the database. Also, arrangements need to be made to detect attempts to reapply deltas and allow process execution to proceed.

Schema delta scripts are run with `psql` against the database that is being updated.

## Delta lifecycle

As the database schema evolves, new _deltas_ can be written to implement the required changes. To keep things tidy, as these _deltas_ get deployed, it's good practice to merge their actions into the default DDL provisioning scripts in the parent directory. This means that whenever a new database is provisioned by the base scripts, the changes introduced by the merged _deltas_ are already deployed.

To prevent spurious errors and useless transformations, the `INSERT` into `schema_errata` at the beginning of each merged _delta_ should be added to the `seed_data.sql` script.
