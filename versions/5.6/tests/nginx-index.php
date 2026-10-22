<?php
if (!extension_loaded('exif') || !extension_loaded('gmp') || !function_exists('mysql_connect')) {
    http_response_code(500);
    exit('Missing PHP compatibility module');
}
$disabled = array_map('trim', explode(',', ini_get('disable_functions')));
foreach (array('exec', 'system', 'popen', 'proc_open', 'shell_exec') as $name) {
    if (!in_array($name, $disabled, true)) { http_response_code(500); exit('Missing function restriction'); }
}
if (ini_get('session.gc_probability') !== '1') { http_response_code(500); exit('Changed session GC'); }
echo 'nginx:' . PHP_VERSION;
