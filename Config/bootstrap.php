<?php
function appVersionSource(?string $file = null): \kbATeam\Version\IVersion
{
    if ($file === null) {
        $file = APP.DS.'webroot'.DS.'commit.json';
    }
    static $version;
    static $versionFile;
    if ($version === null || $file !== $versionFile) {
        $version = new \kbATeam\Version\FileVersion($file);
        if ($version->exists()) {
            $versionFile = $file;
        } else {
            $version = new \kbATeam\Version\GitVersion(APP);
            $versionFile = null;
        }
    }
    return $version;
}

/**
 * Get the current application version from a JSON file or the Git repository.
 * @param string|null $file Path to commit.json; null uses the default location.
 * @return string
 */
function appVersion(?string $file = null): string
{
    $version = appVersionSource($file);
    if ($version->exists()) {
        return sprintf(
            '%s (rev. %s)',
            $version->getBranch(),
            $version->getCommit()
        );
    }
    return '~ ? ~';
}

$version = appVersionSource();
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
