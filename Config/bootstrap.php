<?php
$version = new \kbATeam\Version\FileVersion(APP.DS.'webroot'.DS.'commit.json');
if (!$version->exists()) {
    $version = new \kbATeam\Version\GitVersion(APP);
}
if ($version->exists()) {
    define('APP_VERSION_IDENTIFIER', $version->getBranch());
    define('APP_COMMIT', $version->getCommit());
    define('APP_VERSION', sprintf('%s (rev. %s)', APP_VERSION_IDENTIFIER, APP_COMMIT));
} else {
    define('APP_VERSION_IDENTIFIER', '~ ? ~');
    define('APP_COMMIT', '~ ? ~');
    define('APP_VERSION', '~ ? ~');
}
unset($version);
