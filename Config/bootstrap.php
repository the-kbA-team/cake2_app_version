<?php
/**
 * Get the current application version either from the given file, a default file
 * location or from the current GIT repository.
 * @param string|null $file Manually define the commit.json file. Default: null
 * @return string
 */
function appVersion(?string $file = null): string
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
        }
    }
    if ($version->exists()) {
        return sprintf(
            '%s (rev. %s)',
            $version->getBranch(),
            $version->getCommit()
        );
    }
    return '~ ? ~';
}
define('APP_VERSION', appVersion());
