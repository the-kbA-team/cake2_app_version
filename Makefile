PHP_VERSION ?= 8.1
DEPENDENCIES_LOWEST ?= 0
COMPOSER_IMAGE ?= composer:2
COMPOSER_CACHE_DIR ?= $(HOME)/.cache/composer
COMPOSER_VENDOR_DIR ?= /app/vendor
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

CA_CERT_ARGS = $(if $(CA_CERT_FILE),-v "$(CA_CERT_FILE):/tmp/composer-ca.pem:ro" -e COMPOSER_CAFILE=/tmp/composer-ca.pem)
COMPOSER_DOCKER = docker run --rm -v "$(CURDIR):/app" -w /app -v "$(COMPOSER_CACHE_DIR):/tmp/cache" -e HOST_UID="$(HOST_UID)" -e HOST_GID="$(HOST_GID)" -e COMPOSER_CACHE_DIR=/tmp/cache -e COMPOSER_VENDOR_DIR="$(COMPOSER_VENDOR_DIR)" -e PHP_VERSION="$(PHP_VERSION)" -e DEPENDENCIES_LOWEST="$(DEPENDENCIES_LOWEST)" -e HTTP_PROXY -e HTTPS_PROXY -e NO_PROXY -e http_proxy -e https_proxy -e no_proxy -e GITHUB_TOKEN -e GH_TOKEN -e COMPOSER_AUTH $(CA_CERT_ARGS)
PHP_DOCKER = docker run --rm -v "$(CURDIR):/app" -w /app -e HOST_UID="$(HOST_UID)" -e HOST_GID="$(HOST_GID)" php:$(PHP_VERSION)-cli

.PHONY: help clean check-php-version install lint audit validate analyze

help:
	@printf '%s\n' \
		'install  Resolve dependencies for PHP_VERSION (default: 8.1)' \
		'lint     Check PHP syntax' \
		'analyze  Run PHPStan' \
		'audit    Audit resolved dependencies' \
		'validate Validate composer.json' \
		'clean    Remove generated dependencies and lockfile'

clean:
	docker run --rm -v "$(CURDIR):/app" -w /app --user root alpine:3.20 sh -c 'rm -rf /app/vendor /app/composer.lock'

check-php-version:
	@case "$(PHP_VERSION)" in \
		8.1|8.2|8.3) ;; \
		*) echo "Unsupported PHP_VERSION '$(PHP_VERSION)'; use 8.1, 8.2, or 8.3." >&2; exit 1 ;; \
	esac

install: check-php-version
	@mkdir -p "$(COMPOSER_CACHE_DIR)"
	@set +e; \
	$(COMPOSER_DOCKER) --entrypoint sh $(COMPOSER_IMAGE) -c '\
		if [ -f /tmp/composer-ca.pem ]; then export SSL_CERT_FILE=/tmp/composer-ca.pem; export CURL_CA_BUNDLE=/tmp/composer-ca.pem; export GIT_SSL_CAINFO=/tmp/composer-ca.pem; fi; \
		apk add --no-cache icu-dev $$PHPIZE_DEPS >/dev/null && docker-php-ext-install intl >/dev/null || exit $$?; \
		git config --global --add safe.directory /app; \
		git config --global url."https://github.com/".insteadOf "git@github.com:"; \
		git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"; \
		composer config platform.php "$$PHP_VERSION"; \
		result=$$?; \
		if [ "$$result" -eq 0 ]; then \
			if [ "$$DEPENDENCIES_LOWEST" = "1" ]; then \
				composer update --prefer-lowest --prefer-dist --no-interaction --no-progress; \
			else \
				composer update --prefer-dist --no-interaction --no-progress; \
			fi; \
			result=$$?; \
		fi; \
		composer config --unset platform.php >/dev/null 2>&1 || true; \
		composer config --unset platform >/dev/null 2>&1 || true; \
		if [ -n "$$HOST_UID" ] && [ -n "$$HOST_GID" ]; then chown -R "$$HOST_UID:$$HOST_GID" vendor composer.lock 2>/dev/null || true; fi; \
		rm -f composer.lock; \
		exit "$$result"'; \
	result=$$?; \
	rm -f composer.lock; \
	exit $$result

lint: check-php-version
	$(PHP_DOCKER) sh -c 'find Config -type f -name "*.php" -print0 | xargs -0 -n1 php -l && php -l php_bootstrap.php'

analyze: check-php-version
	$(PHP_DOCKER) php "$(COMPOSER_VENDOR_DIR)/bin/phpstan" analyse --no-progress

audit: check-php-version
	@mkdir -p "$(COMPOSER_CACHE_DIR)"
	@set +e; \
	$(COMPOSER_DOCKER) --entrypoint sh $(COMPOSER_IMAGE) -c '\
		if [ -f /tmp/composer-ca.pem ]; then export SSL_CERT_FILE=/tmp/composer-ca.pem; export CURL_CA_BUNDLE=/tmp/composer-ca.pem; export GIT_SSL_CAINFO=/tmp/composer-ca.pem; fi; \
		apk add --no-cache icu-dev $$PHPIZE_DEPS >/dev/null && docker-php-ext-install intl >/dev/null || exit $$?; \
		git config --global --add safe.directory /app; \
		git config --global url."https://github.com/".insteadOf "git@github.com:"; \
		git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"; \
		composer config platform.php "$$PHP_VERSION"; \
		result=$$?; \
		if [ "$$result" -eq 0 ]; then \
			if [ "$$DEPENDENCIES_LOWEST" = "1" ]; then \
				composer update --prefer-lowest --prefer-dist --no-interaction --no-progress; \
			else \
				composer update --prefer-dist --no-interaction --no-progress; \
			fi; \
			result=$$?; \
		fi; \
		if [ "$$result" -eq 0 ]; then composer audit; result=$$?; fi; \
		composer config --unset platform.php >/dev/null 2>&1 || true; \
		composer config --unset platform >/dev/null 2>&1 || true; \
		if [ -n "$$HOST_UID" ] && [ -n "$$HOST_GID" ]; then chown -R "$$HOST_UID:$$HOST_GID" vendor composer.lock 2>/dev/null || true; fi; \
		rm -f composer.lock; \
		exit "$$result"'; \
	result=$$?; \
	rm -f composer.lock; \
	exit $$result

validate:
	docker run --rm -v "$(CURDIR):/app" -w /app --entrypoint sh $(COMPOSER_IMAGE) -c 'git config --global --add safe.directory /app && git config --global url."https://github.com/".insteadOf "git@github.com:" && git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" && composer validate --strict'
