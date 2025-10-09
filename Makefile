setup: list-cortex-repositories
	chmod +x ./list-cortex-repositories
	sudo cp ./list-cortex-repositories /usr/local/bin/list-cortex-repositories

uninstall:
	sudo rm -f /usr/local/bin/list-cortex-repositories

.PHONY: setup uninstall
