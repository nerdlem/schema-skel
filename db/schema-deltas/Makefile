# This Makefile is not meant to be used directly, so the rule below provides
# adequate notes.

all:
	@echo This Makefile is not meant to be invoked directly. It is used as part
	@echo of the schema delta infrastructure. Consult the README file in this
	@echo directory for more information.
	@exit 255


# The following rule is an example used to simply mask the error intentionally
# caused by the corresponding schema delta script. In your own scripts, you need
# to make sure that the required tag ('000000-sample') is added to the
# schema_errata table to ensure this rule is not executed continuously. These
# rules need to return a success value to ensure the process is not stopped.

000000-sample:
