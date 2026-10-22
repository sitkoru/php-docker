# PHP

Образы для сайтов: `fpm`, `dev`, `ssh`, `with-nginx`, `with-nginx-ssh`.
CI проверяет PHP 7.4.33 / Bullseye, 8.0.30 / Bullseye,
8.1.34 / Bookworm и 8.2.35 / Bookworm на `linux/amd64`.
Набор расширений сохранён; версии PECL закреплены в `install.sh` и `install_dev.sh`.
PostgreSQL и nginx устанавливаются из подписанных репозиториев Debian.

## Исправления PHP

PHP 7.4, 8.0 и 8.1 пересобираются из исходников, вложенных в официальный образ,
с исходными параметрами `php-config --configure-options`, путями и ABI.
`rebuild-php.sh` проверяет SHA256 официальных патчей перед применением без fuzz:

| PHP | Официальный commit PHP | SHA256 патча |
| --- | --- | --- |
| 7.4.33 | `712e60f9edfd03f0960fc4fc3c2c375f42b90aa2` | `5fe57ca6ee96d59b36c6e0ca842843c50884f177bef1e85234cf669b577f5e48` |
| 8.0.30 | `82f8f31b16a035c1b67cc253e79f7cc288f4cc20` | `534478c973cef6f493605b7af907f639a364912ee92c24598ddae44c3bc72d1c` |
| 8.1.34 | `1d7dec178a094e6e75b229ce22754045f8c6070a` | `c85ad0fddcbff7f2318617eeaa54d271135463b5bf70a01228447e3ed78de96e` |

Источник: `https://github.com/php/php-src/commit/<commit>.patch`.
Upstream называет эти изменения минимальной mitigation для EOL-веток
(CVE-2026-109618 и CVE-2026-109619). Они отключают session upload progress
и завершают процесс при исчерпании памяти без выполнения пользовательских
обработчиков завершения. Это изменение поведения нужно учитывать приложениям.
PHP 8.2.35 используется из официального образа без локального патча.

PHP 7.4/8.0/8.1 и Debian Bullseye завершили поддержку.
Перенос двух исправлений не означает наличия всех исправлений после EOL,
полноценной поддержки или проверки совместимости сайтов.
Bullseye security доступен через архив; проверка подписей APT сохранена.

## Проверка без публикации

```sh
docker build --platform linux/amd64 --target fpm \
  --build-arg PHP_VERSION=7.4.33 --build-arg DEBIAN_VERSION=bullseye \
  -t php-verify:fpm .
python3 tests/verify.py php-verify:fpm fpm
```

В сборке выполняются upstream PHPT `tests/basic/001.phpt` и
`ext/session/tests/session_basic1.phpt`: это базовые проверки CLI и session,
не регрессии конкретных CVE. Официальные EOL-патчи не добавляют PHPT.
`tests/verify.py` проверяет реальный CLI, обязательные расширения, конфигурацию
и запрос FastCGI к FPM, наличие инструментов соответствующего варианта,
а для EOL-веток — завершение при OOM без shutdown callback.
Контейнеры ограничены по памяти и числу процессов; OOM запускается без сети.
Это не полная проверка эксплуатации CVE и не проверка приложений.

PR и ручной запуск `workflow_dispatch` только собирают и проверяют локальные образы.
Push запускает матрицу только для `master`, чтобы не дублировать проверки PR.
Semantic release разрешён только после успешной матрицы на push `master`;
публикация образов запускается отдельным событием `release: released`.
Существующий `sitkoru/semantic-release-action@v2` пока сохранён;
его внутренний Node.js 16 требует отдельной проверки обновления.
Теги `-nginx-ssh` теперь соответствуют `with-nginx-ssh` и не перезаписывают `-nginx`.
