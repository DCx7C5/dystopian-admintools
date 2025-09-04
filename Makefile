PREFIX = /usr

SHELL := sh

.PHONY: \
	install uninstall setup remove all backup \
	setup-hosts-part setup-aurtool-part \
	remove-hosts remove-aurtool bkp-tool


install: setup
uninstall: remove
remove: remove-hosts remove-aurtool
setup-hosts: setup-hosts-part
setup-aurtool: setup-aurtool-part
setup: setup-hosts-part setup-aurtool-part
all: setup

setup-hosts-part:
	install -m 750 bin/dystopian-hosts $(PREFIX)/bin/dystopian-hosts
	install -d -m 755 /etc/dystopian-hosts
	install -m 600 conf/hosts-db.json /etc/dystopian-hosts/hosts-db.json

setup-aurtool-part:
	install -m 750 bin/dystopian-aurtool $(PREFIX)/bin/dystopian-aurtool
	install -d -m 755 /etc/dystopian-aurtool
	install -m 600 conf/aurtool-db.json /etc/dystopian-aurtool/aurtool-db.json

remove-hosts: SRC = dystopian-hosts
remove-hosts: bkp-tool
remove-hosts:
	rm -f $(PREFIX)/bin/dystopian-hosts
	rm -f /etc/dystopian-hosts/hosts-db.json
	rmdir /etc/dystopian-hosts || true

remove-aurtool: SRC = dystopian-aurtool
remove-aurtool: bkp-tool
remove-aurtool:
	rm -f $(PREFIX)/bin/dystopian-aurtool
	rm -f /etc/dystopian-aurtool/aurtool-db.json
	rmdir /etc/dystopian-aurtool || true

bkp-tool:
	@set -eu; \
	. $(PREFIX)/lib/dystopian-libs/libadmintools-variables.sh; \
	. $(PREFIX)/lib/dystopian-libs/libadmintools-helper.sh; \
	: "$${SRC:?Set SRC to a directory name (e.g. dystopian-hosts) or absolute path}"; \
	case "$$SRC" in \
		/*) _path="$$SRC" ;; \
		*)  _path="/etc/$$SRC" ;; \
	esac; \
	backup_targz "$$_path"
