# This is the main Makefile for this project. It depends on Makefiles located
# further inside the subdirectories of this distribution.

PGRESTCONFIG=postgrest.config
PGRESTTMUXNAME=launch-rest-test

all:
	@echo Please select one or more targets to make:
	@echo ""
	@echo test -- update perl dependencies, deploy and test schema and perl API
	@echo deploy -- deploy database with all deltas. Use environment variables to customize
	@echo destroy -- remove the database schema. Use env variables to customize

test: db-test destroy

db-test: deploy
	( cd db; PSQLRC=psqlrc-test make test )

deploy:
	( cd db; PSQLRC=psqlrc-test make all deltas )

destroy:
	( cd db; PSQLRC=psqlrc-test make destroy )
