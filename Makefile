setup: list-cortex-repositories
	chmod +x ./list-cortex-repositories
	sudo cp ./list-cortex-repositories /usr/local/bin/list-cortex-repositories

uninstall:
	sudo rm -f /usr/local/bin/list-cortex-repositories

test:
	shellcheck list-cortex-repositories
	bats tests

.PHONY: setup uninstall test
