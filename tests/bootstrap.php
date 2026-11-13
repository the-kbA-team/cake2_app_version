<?php

if (isset($argv[1])) {
    require __DIR__ . '/../vendor/autoload.php';
    define('DS', DIRECTORY_SEPARATOR);
    define('APP', $argv[1]);
    require __DIR__ . '/../Config/bootstrap.php';

    $actual = [APP_VERSION_IDENTIFIER, APP_COMMIT, APP_VERSION];
    if (isset($argv[3])) {
        $actual[] = appVersion($argv[3]);
        $actual[] = appVersion(APP . '/missing.json');
        $actual[] = appVersion($argv[3]);
        $actual[] = APP_VERSION_IDENTIFIER;
        $actual[] = APP_COMMIT;
        $actual[] = APP_VERSION;
    }
    $expected = json_decode($argv[2], true, 512, JSON_THROW_ON_ERROR);
    if ($actual !== $expected) {
        throw new RuntimeException('Expected ' . json_encode($expected) . ', got ' . json_encode($actual));
    }
    exit;
}

$directory = sys_get_temp_dir() . '/app-version-' . bin2hex(random_bytes(8));
mkdir($directory);

try {
    mkdir($directory . '/webroot');
    mkdir($directory . '/.git');
    mkdir($directory . '/.git/refs');
    mkdir($directory . '/.git/refs/heads');
    file_put_contents($directory . '/.git/HEAD', "ref: refs/heads/main\n");
    file_put_contents($directory . '/.git/refs/heads/main', "abcdef1234567890abcdef1234567890abcdef12\n");
    $commitFile = $directory . '/webroot/commit.json';
    $customFile = $directory . '/custom.json';
    file_put_contents($customFile, '{"branch":"v9.0.0","commit":"987654321"}');

    $check = static function (array $expected, ?string $custom = null) use ($directory): void {
        $command = [PHP_BINARY, __FILE__, $directory, json_encode($expected, JSON_THROW_ON_ERROR)];
        if ($custom !== null) {
            $command[] = $custom;
        }
        $process = proc_open($command, [0 => ['file', '/dev/null', 'r'], 1 => STDOUT, 2 => STDERR], $pipes);
        if (!is_resource($process) || proc_close($process) !== 0) {
            throw new RuntimeException('Bootstrap behavior test failed.');
        }
    };

    file_put_contents($commitFile, '{"branch":"v2.3.4","commit":"abcdef123"}');
    $check([
        'v2.3.4', 'abcdef123', 'v2.3.4 (rev. abcdef123)',
        'v9.0.0 (rev. 987654321)', 'main (rev. abcdef1)', 'v9.0.0 (rev. 987654321)',
        'v2.3.4', 'abcdef123', 'v2.3.4 (rev. abcdef123)'
    ], $customFile);

    file_put_contents($commitFile, '{"branch":"incomplete"}');
    $check(['main', 'abcdef1', 'main (rev. abcdef1)']);

    unlink($commitFile);
    $check(['main', 'abcdef1', 'main (rev. abcdef1)']);

    unlink($directory . '/.git/refs/heads/main');
    $check(['~ ? ~', '~ ? ~', '~ ? ~']);

    file_put_contents($commitFile, '{"branch":"","commit":""}');
    $check(['', '', ' (rev. )']);

    echo "Bootstrap behavior tests passed.\n";
} finally {
    foreach ([$commitFile ?? '', $customFile ?? '', $directory . '/.git/refs/heads/main', $directory . '/.git/HEAD'] as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }
    foreach (['/.git/refs/heads', '/.git/refs', '/.git', '/webroot', ''] as $path) {
        if (is_dir($directory . $path)) {
            rmdir($directory . $path);
        }
    }
}
