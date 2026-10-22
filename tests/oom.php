<?php
// Исправление upstream завершает процесс до вызова пользовательского shutdown-кода.
register_shutdown_function(function () { echo "UNSAFE_SHUTDOWN\n"; });
str_repeat('x', 64 * 1024 * 1024);
