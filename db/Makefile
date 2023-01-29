PGNAMESPACE ?= skel

export PGNAMESPACE

all: deploy

# The deploy target executes the DDL files in the required order.

deploy:
	@./deploy.sh

deltas:
	@./deltas.sh

destroy:
	@./destroy.sh

test:
	@./test.sh
