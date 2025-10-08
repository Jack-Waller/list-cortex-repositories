setup: list-repositories
	chmod +x ./list-repositories
	sudo cp ./list-repositories /usr/local/bin/list-repositories

uninstall:
	sudo rm -f /usr/local/bin/list-repositories

.PHONY: setup uninstall
