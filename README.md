# PHP

Образы PHP 5.6, 7.2, 7.4, 8.0, 8.1 и 8.2 используют Debian 13 и
[подписанный репозиторий Surý](https://packages.sury.org/php/dists/trixie/).
PHP, расширения и CGI для тестов устанавливаются готовыми пакетами.
Обе матрицы GitHub Actions закрепляют версии пакетов PHP-FPM и CLI.

`versions/package/Dockerfile` собирает варианты `fpm`, `dev`, `ssh`, `with-nginx`
и `with-nginx-ssh` для PHP 7.2–8.2. По умолчанию выбирается PHP 7.2. Для другой
ветки передайте `PHP_BRANCH`, `PHP_VERSION` и `PHP_PACKAGE_VERSION` из матрицы
`.github/workflows/main.yml`.

`versions/5.6/Dockerfile` собирает `fpm`, `dev` и `with-nginx` для PHP 5.6.
В этом варианте Nginx и его TLS-библиотеки также устанавливаются из пакетов.

## Интерфейс контейнеров

FPM слушает порт 9000. Пути для монтирования конфигурации — `/usr/local/etc/php-fpm.conf`,
`/usr/local/etc/php/php.ini` и `/usr/local/etc/php/conf.d`. Пакетные расширения
загружаются из `/etc/php/<ветка>/<SAPI>/conf.d`, затем читаются дополнительные
настройки образа. Пакеты включают `pcntl` в CLI. PHP-FPM использует пакетный
набор модулей без `pcntl`. В варианте `dev` действуют встроенные настройки PHP
и конфигурация модулей. `PHP_VERSION` включает ревизию пакета, `PHP_VERSION_ID`
возвращает числовую версию языка.

Вариант PHP 5.6 с Nginx открывает порт 80, читает `APP_BEFORE_START_SCRIPT`,
отдаёт `/fpm-status-page` и пишет журналы в потоки контейнера. Этот вариант
включает `mysql`, `exif`, `gmp` и `msmtp` для совместимости с потребителями.
Для PHP 5.6 в варианте `dev` используется Composer 2.2 LTS.

## Локальные проверки

```sh
docker build --platform linux/amd64 -f versions/package/Dockerfile \
  --target fpm -t php72-package:fpm .
python3 tests/verify.py php72-package:fpm fpm
docker build --platform linux/amd64 -f versions/package/Dockerfile --target regression .
docker build --platform linux/amd64 -f versions/5.6/Dockerfile --target verify .
docker build --platform linux/amd64 -f versions/5.6/Dockerfile --target regression .
```

`tests/verify.py` проверяет пакетную базу, CLI, расширения, конфигурацию
и ответ FPM на FastCGI, а также инструменты конкретного варианта.
Проверки PHP 5.6 дополнительно охватывают HTTP через Nginx, запуск
`APP_BEFORE_START_SCRIPT` и журналы контейнера.

Цели `regression` для PHP 5.6 и 7.2 выполняют PHPT для multipart и сессий
с готовым CGI. Архив PHP используется для `run-tests.php` и тестовых данных.

## Теги образов

| Вариант | Теги |
| --- | --- |
| PHP 7.2–8.2, `fpm` | `ghcr.io/sitkoru/php:<полная версия>` и `:<major.minor>` |
| PHP 7.2–8.2, `dev` / `ssh` / `with-nginx` / `with-nginx-ssh` | Те же версии с суффиксом `-dev` / `-ssh` / `-nginx` / `-nginx-ssh` |
| PHP 5.6, `fpm` | `ghcr.io/sitkoru/php5:latest`, `:sha-<commit8>` |
| PHP 5.6, `dev` | `ghcr.io/sitkoru/php5-dev:latest`, `:sha-<commit8>` |
| PHP 5.6, `with-nginx` | `ghcr.io/sitkoru/php:5.6-nginx`, `:5.6.40-nginx` |

PR и ручной запуск основного workflow проверяют образы. Push в `master`
запускает проверку и semantic-release. Образы публикует отдельный workflow
по событию `release: released`. У тегов `php5:latest` и `php5-dev:latest`
должен быть один издатель. Проверяйте старые workflows `sitkoru/docker-php5`
перед изменением порядка публикации.
