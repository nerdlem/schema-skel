# This is the main Makefile for this project. It depends on Makefiles located
# further inside the subdirectories of this distribution.

PGRESTCONFIG=postgrest.config

all:
	@echo Please select one or more targets to make:
	@echo ""
	@echo test -- deploy and test schema
	@echo deploy -- deploy database with all deltas. Use environment variables to customize
	@echo destroy -- remove the database schema. Use env variables to customize
	@echo launch -- launch a Docker environment to expose your local database via PostgREST

test: db-test destroy

db-test: deploy
	@( cd db; PSQLRC=psqlrc-test $(MAKE) test )

deploy:
	@( cd db; PSQLRC=psqlrc-test $(MAKE) all deltas )

destroy:
	@( cd db; PSQLRC=psqlrc-test $(MAKE) destroy )

launch:
	@( cd db; source ./setup.sh; docker compose --file ../Docker/pgrst-api-dev-compose.yml up )
