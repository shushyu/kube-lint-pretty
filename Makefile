PREFIX ?= /usr/local

.PHONY: install uninstall lint test
install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 kube-lint-pretty $(DESTDIR)$(PREFIX)/bin/kube-lint-pretty
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/kube-lint-pretty
lint:
	shellcheck kube-lint-pretty test/run.sh
test:
	bash test/run.sh
