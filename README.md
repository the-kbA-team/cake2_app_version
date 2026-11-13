# CakePHP 2.x AppVersion

CakePHP 2.x plugin to determine the current version of your application. The version is either taken from the commit.json of the deploy script or from the local clone of the git repository.

## Usage

```php
<?php
echo constant('APP_VERSION');
// Separate identifiers, e.g. for structured logging:
echo APP_VERSION_IDENTIFIER;
echo APP_COMMIT;
```

`APP_VERSION_IDENTIFIER` is the release tag or Git ref recorded in
`commit.json`, or the local Git branch when the file is unavailable.
`APP_COMMIT` is the abbreviated commit SHA as provided by the source. When
neither source provides both values, each constant contains `~ ? ~`.
`APP_VERSION` retains the combined `identifier (rev. commit)` format and its
existing fallback. The plugin reads `APP/webroot/commit.json`; custom file
paths are no longer supported.

The constants are set once at bootstrap. Restart long-running workers after a
deployment to pick up the new values. Applications can add the separate
constants to their own logging configuration; this plugin does not configure
Graylog.

## Installation

1. Require the plugin.
```bash
composer require kba-team/cake2_app_version
```
2. Include the plugin in your `bootstrap.php`
```php
<?php
CakePlugin::load('AppVersion', ['bootstrap' => true, 'routes' => false]);
```

## Development

The Makefile runs Composer and PHP tools in Docker. Supported PHP versions are
8.1, 8.2, and 8.3.

```bash
make install PHP_VERSION=8.1
make lint PHP_VERSION=8.1
make test PHP_VERSION=8.1
make analyze PHP_VERSION=8.1
make audit PHP_VERSION=8.1
make validate
```

Use `DEPENDENCIES_LOWEST=1` with `make install` to resolve the lowest allowed
dependency versions.

Distribution archives contain the plugin bootstrap, Composer metadata, and
license. Composer source installations use a full repository checkout instead.
