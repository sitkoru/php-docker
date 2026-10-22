# PHP

Образы для сайтов: PHP 7.4–8.2 имеют `fpm`, `dev`, `ssh`, `with-nginx`,
`with-nginx-ssh`; PHP 5.6 имеет `fpm`, `dev` и `with-nginx`.
CI проверяет PHP 5.6.40 / Stretch, PHP 7.4.33 / Bullseye, 8.0.30 / Bullseye,
8.1.34 / Bookworm и 8.2.35 / Bookworm на `linux/amd64`.
Набор расширений сохранён; версии PECL закреплены в отдельных Dockerfile, SHA256 архивов — в
`scripts/pecl-sha256.txt` и Dockerfile PHP 5.6.
Веткам 7.4–8.2 PostgreSQL и nginx предоставляет подписанный репозиторий Debian.
Для PHP 5.6 nginx собирается отдельно, см. ниже.

## Структура

`versions/<ветка>/Dockerfile` явно задаёт базовый образ, патч и расширения своей
ветки; build context всегда корень репозитория. Общие скрипты в `scripts/`
выполняют одинаковые операции и не выбирают поведение по `PHP_VERSION`.
Общие конфиги остаются в корне и `nginx/`. Отличающиеся конфиги и entrypoint
PHP 5.6 сохранены в `versions/5.6/`: объединение не меняет обработку hook,
журналов и жизненного цикла процессов остальных образов.

## Исправления PHP

PHP 7.4, 8.0 и 8.1 пересобираются из исходников, вложенных в официальный образ,
с исходными параметрами `php-config --configure-options`, путями и ABI.
`scripts/rebuild-php.sh` проверяет SHA256 официальных патчей перед применением без fuzz:

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

PHP 5.6/7.4/8.0/8.1 и Debian Stretch/Bullseye завершили поддержку.
Перенос двух исправлений не означает наличия всех исправлений после EOL,
полноценной поддержки или проверки совместимости сайтов.
Bullseye security доступен через архив; проверка подписей APT сохранена.

## Проверка без публикации

```sh
docker build --platform linux/amd64 -f versions/7.4/Dockerfile \
  --target fpm -t php-verify:fpm .
python3 tests/verify.py php-verify:fpm fpm
```

В сборках 7.4–8.2 выполняются upstream PHPT `tests/basic/001.phpt` и
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
`sitkoru/semantic-release-action` закреплён на коммите с Node.js 24;
он требует Actions Runner v2.327.1 или новее. Изменение release-action проверено
статически; настоящий выпуск и совместимость npm-пакетов выполнением не проверялись.
Теги `-nginx-ssh` теперь соответствуют `with-nginx-ssh` и не перезаписывают `-nginx`.


## PHP 5.6

Перенесён из `sitkoru/docker-php5`, commit `65282c4`, с отдельными настройками
FPM/dev. Источник и SHA256 трёх Debian backport-патчей описаны в
[versions/5.6/patches/README.md](versions/5.6/patches/README.md).
Применяются CVE-2026-109618/CVE-2026-109619 и связанный multipart-лимит
CVE-2023-0662. Обычные загрузки файлов сохраняются, session upload progress
отключается, OOM завершает процесс без пользовательского shutdown callback.

`with-nginx` сохраняет интерфейс `ghcr.io/sitkoru/php:5.6-nginx`: порт 80,
PHP-FPM 9000, `APP_BEFORE_START_SCRIPT`, прежние пути конфигов nginx,
`/fpm-status-page`, `mysql`, `exif`, `gmp`, `msmtp` и пользователя `www-data`.
Nginx 1.30.6 собирается с отдельным статическим OpenSSL 3.5.9, не меняя SSL ABI
PHP. URL и SHA256 закреплены в `versions/5.6/nginx/build.sh`.
Dev сохраняет Xdebug 2.5.5 и совместимый Composer 2.2 LTS.

```sh
docker build --platform linux/amd64 -f versions/5.6/Dockerfile --target verify .
docker build --platform linux/amd64 -f versions/5.6/Dockerfile --target regression .
docker build --platform linux/amd64 -f versions/5.6/Dockerfile \
  --target with-nginx -t php5-check:nginx .
```

Проверки `versions/5.6/tests` запускают настоящее ядро, модули, GD/intl,
OOM, FastCGI-запрос, четыре upstream PHPT multipart/session и собственный
PHPT отключения upload progress с успешной загрузкой файла. Проверка nginx
проходит через HTTP в PHP, выполняет фиктивный startup hook и проверяет
access/error в `docker logs`. Приложения сайтов и внешние БД не участвуют.

## Имена образов при будущем выпуске

| Dockerfile и target | Теги |
| --- | --- |
| 7.4–8.2, `fpm` | `ghcr.io/sitkoru/php:<полная версия>` и `:<major.minor>` |
| 7.4–8.2, `dev` / `ssh` / `with-nginx` / `with-nginx-ssh` | Те же версии с суффиксом `-dev` / `-ssh` / `-nginx` / `-nginx-ssh` |
| 5.6, `fpm` | `ghcr.io/sitkoru/php5:latest`, `:sha-<commit8>` |
| 5.6, `dev` | `ghcr.io/sitkoru/php5-dev:latest`, `:sha-<commit8>` |
| 5.6, `with-nginx` | `ghcr.io/sitkoru/php:5.6-nginx`, `:5.6.40-nginx` |

Исторические теги `php5`/`php5-dev` вида `vX.Y.Z`, `vX.Y`, `vX` и `edge`
не переназначаются под независимый цикл релизов `php-docker`.
**Перед первым выпуском PHP5 из этого репозитория нужно отдельно переключить
издателя:** старый `docker-php5` пока сохраняет собственные workflows публикации.
Иначе два репозитория смогут перезаписывать `latest`. Слияние, переключение
издателя, выпуск и обновление production в эту проверочную работу не входят.
