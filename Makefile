.DEFAULT_GOAL := help

GPG = $(shell command -v gpg2 || command -v gpg)
ifeq ($(GPG),)
$(error "gpg2 or gpg not found in PATH")
endif
GPG_MAJOR_VERSION = $(shell $(GPG) --version | awk 'NR==1 { split($$3,version,"."); print version[1]}')

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: import-and-sign
import-and-sign: ## Import in GPG all keys from the list of allowed keys
	$(foreach var,$(shell find . -name .gpg-id | xargs cat | sort | uniq | cut -c 33-40), \
		( \
			$(GPG) --list-public-key $(var) || \
			$(GPG) --keyserver hkp://keyserver.ubuntu.com:80 --search-keys $(var); \
		) && \
		$(GPG) --sign-key $(var); \
	)

.PHONY: list-keys
list-keys: ## List all the keys in the store with ID and names
	@for key in $$(cat .gpg-id); do \
		printf "$${key}: "; \
		if [ "$(GPG_MAJOR_VERSION)" = "2" ]; then \
			$(GPG) --list-keys --with-colons $$key 2> /dev/null | awk -F: '/^uid/ {found = 1; print $$10; exit} END {if (found != 1) {print "*** not found in local keychain ***"}}'; \
		else \
			$(GPG) --list-keys --with-colons $$key 2> /dev/null | awk -F: '/^pub/ {found = 1; print $$10} END {if (found != 1) {print "*** not found in local keychain ***"}}'; \
		fi;\
	done

.PHONY: check-pass-store
check-pass-store: ## Check if you can read all the keys
	@for i in $$(find . -name '*.gpg' | sed 's/\.gpg$$//;s/^.\///'); do \
		echo "Checking $$i"; \
		PASSWORD_STORE_DIR=$$(pwd) pass $$i > /dev/null || exit 1; \
	done
	@echo "OK: All password entries are readable"

.PHONY: reencrypt
reencrypt:
	pass init --path=. $(shell cat .gpg-id)

.PHONY: publish-public-keys
publish-public-keys:
	$(GPG) --keyserver hkp://keyserver.ubuntu.com:80 --send-keys $(shell cat .gpg-id)
