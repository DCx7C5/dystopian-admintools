PREFIX = /usr

SHELL := sh

.PHONY: \
	install uninstall setup remove all backup \
	setup-shared  setup-hosts-part setup-aurtool-part \
	remove-shared remove-crypto remove-hosts \
	remove-aurtool bkp-tool


install: setup
uninstall: remove
remove: remove-hosts remove-aurtool remove-shared
setup-hosts: setup-shared setup-hosts-part
setup-aurtool: setup-shared setup-aurtool-part
setup: setup-shared setup-hosts-part setup-aurtool-part
all: setup

setup-shared:
	install -d -m 755 $(PREFIX)/lib/dystopian-admintools
	install -m 640 lib/variables.sh $(PREFIX)/lib/dystopian-admintools/variables.sh
	install -m 640 lib/helper.sh $(PREFIX)/lib/dystopian-admintools/helper.sh

	install -d -m 755 $(PREFIX)/share/doc/dystopian-admintools
	install -m 644 README.md $(PREFIX)/share/doc/dystopian-admintools/README.md

setup-hosts-part:
	install -m 750 bin/dystopian-hosts $(PREFIX)/bin/dystopian-hosts
	install -d -m 755 /etc/dystopian-hosts
	install -m 600 conf/hosts-db.json /etc/dystopian-hosts/hosts-db.json
	install -m 640 lib/crypto-db.sh $(PREFIX)/lib/dystopian-admintools/hosts-db.sh
	install -m 640 lib/hosts.sh $(PREFIX)/lib/dystopian-admintools/hosts.sh

setup-aurtool-part:
	install -m 750 bin/dystopian-aurtool $(PREFIX)/bin/dystopian-aurtool
	install -d -m 755 /etc/dystopian-aurtool
	install -m 600 conf/aurtool-db.json /etc/dystopian-aurtool/aurtool-db.json
	install -m 640 lib/aurtool-db.sh $(PREFIX)/lib/dystopian-admintools/aurtool-db.sh
	install -m 640 lib/aurtool.sh $(PREFIX)/lib/dystopian-admintools/aurtool.sh

remove-shared:
	rm -f $(PREFIX)/lib/dystopian-admintools/variables.sh
	rm -f $(PREFIX)/lib/dystopian-admintools/helper.sh
	rm -f $(PREFIX)/lib/dystopian-admintools/ssl.sh
	rm -f $(PREFIX)/lib/dystopian-admintools/gpg.sh
	rm -f $(PREFIX)/lib/dystopian-admintools/secboot.sh
	rm -f $(PREFIX)/lib/dystopian-admintools/crypto-db.sh
	rm -f $(PREFIX)/lib/dystopian-admintools/secboot-db.sh
	rm -f $(PREFIX)/lib/dystopian-admintools/hosts.sh
	rmdir $(PREFIX)/lib/dystopian-admintools || true
	rm -f $(PREFIX)/share/doc/dystopian-admintools/README.md
	rmdir $(PREFIX)/share/doc/dystopian-admintools || true

remove-hosts: SRC = dystopian-hosts
remove-hosts: bkp-tool
remove-hosts:
	rm -f $(PREFIX)/bin/dystopian-hosts
	rm -f $(PREFIX)/lib/dystopian-admintools/hosts-db.sh
	rm -f /etc/dystopian-hosts/hosts-db.json
	rmdir /etc/dystopian-hosts || true

remove-aurtool: SRC = dystopian-aurtool
remove-aurtool: bkp-tool
remove-aurtool:
	rm -f $(PREFIX)/bin/dystopian-aurtool
	rm -f $(PREFIX)/lib/dystopian-admintools/aurtool-db.sh
	rm -f /etc/dystopian-aurtool/aurtool-db.json
	rmdir /etc/dystopian-aurtool || true

bkp-tool:
	@set -eu; \
	. $(PREFIX)/lib/dystopian-admintools/variables.sh; \
	. $(PREFIX)/lib/dystopian-admintools/helper.sh; \
	: "$${SRC:?Set SRC to a directory name (e.g. dystopian-hosts) or absolute path}"; \
	case "$$SRC" in \
		/*) _path="$$SRC" ;; \
		*)  _path="/etc/$$SRC" ;; \
	esac; \
	backup_targz "$$_path"
