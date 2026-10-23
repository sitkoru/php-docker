# Источник исправлений

Патчи без изменений из [Debian PHP Maintainers](https://salsa.debian.org/php-team/php/-/tree/e0bcd488d9f8da024d9e1a254113539a846cac6d/debian/patches), commit `e0bcd488d9f8da024d9e1a254113539a846cac6d`.

| Файл | SHA256 |
| --- | --- |
| 0104-Fix-repeated-warning-for-file-uploads-limit-exceedin.patch | `344f687765cf6192fdfea9065e5ffbce4f77840ff496007c3c2f757458394997` |
| 0105-Introduce-max_multipart_body_parts-INI.patch | `51e0a7758fce1fa44f0804313307171adb209504e0951b07f7fd2f1bc6c6a604` |
| 0135-backport-ZSTR_MAX_LEN.patch | `b4da10ce4bb9aaf57dc3de71f21d200a5a331aec7c34b8c7b946b1db3b9c7e1f` |
| 0159-Avoid-state-corruption-via-bailout.patch | `35f4820ab80594899db860be6f6d695657509d6186a830fefd5f442bc2bd0330` |

0159 переносит официальную минимальную mitigation PHP 7.4 для CVE-2026-109618/CVE-2026-109619 с адаптацией API Zend 7.2. Зависимости: 0104/0105 задают лимит multipart (CVE-2023-0662), 0135 добавляет используемый предел ZSTR_MAX_LEN. Все четыре патча применяются к PHP 7.2.34 без fuzz. Это не полный набор исправлений после EOL.
