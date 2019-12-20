# CakePHP AppVersion

CakePHP plugin to determine the current version of your application. The version is either taken from the commit.json of the deploy script or from the local clone of the git repository.

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
