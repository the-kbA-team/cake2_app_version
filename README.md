# CakePHP 2.x AppVersion

CakePHP 2.x plugin to determine the current version of your application. The version is either taken from the commit.json of the deploy script or from the local clone of the git repository.

## Usage

```php
<?php
echo constant('APP_VERSION');
//or
echo appVersion();
```

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
make analyze PHP_VERSION=8.1
make audit PHP_VERSION=8.1
make validate
```

Use `DEPENDENCIES_LOWEST=1` with `make install` to resolve the lowest allowed
dependency versions.
