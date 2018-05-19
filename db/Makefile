all: deploy

# The deploy target executes the DDL files in the required order.

deploy:
	psql -f extensions.ddl
	psql -f domains.ddl
	psql -f functions.ddl
	psql -f schema.ddl
	psql -f schema-deltas.ddl
	psql -f views.ddl
	psql -f triggers.ddl
	psql -f roles.ddl
	psql -f seed_data.sql

schema_errata.csv: FORCE
	rm -f $@
	PSQLRC=psqlrc-delta psql -c \
		"\COPY (SELECT delta FROM schema_errata) TO '$@' WITH CSV;"
	echo @ >> $@

FORCE:

deltas: schema_errata.csv
	find ./schema-deltas -type f -name '*.sql' |\
	 grep --invert-match --fixed-strings --file $< |\
	  while read delta; do \
			echo Applying $$delta... ;\
	  	PSQLRC=psqlrc-delta psql -f $$delta || \
				( cd schema-deltas; make --quiet `basename $$delta .sql` ) || \
					exit 255; \
	done

destroy:
	psql -f destroy.ddl
	rm -f schema_errata.csv

# The test target is meant to initiate a test suite. In most of my projects I
# try to use pg_prove, a companion to the pg_tap extension. See
# http://pgtap.org/

test:
	pg_prove --recurse t/
