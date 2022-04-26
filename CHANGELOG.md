# [1.24.0](https://github.com/sitkoru/php-docker/compare/v1.23.0...v1.24.0) (2022-04-26)


### Features

* **php:** PHP 7.4.29 and 8.0.18 ([f17546c](https://github.com/sitkoru/php-docker/commit/f17546c5fef19a14d36f2f0aea56fd4d3deacd93))

# [1.23.0](https://github.com/sitkoru/php-docker/compare/v1.22.0...v1.23.0) (2022-03-29)


### Features

* php 7.4.28 and 8.0.17 ([e7f4302](https://github.com/sitkoru/php-docker/commit/e7f43023fde7d189e43e870d92d89ac590fe13d7))
* **php:** PHP 7.3.33 ([130b37b](https://github.com/sitkoru/php-docker/commit/130b37b3333667c2a676a6051cd4abefe776c92e))
* **php:** PHP 7.4.26 ([7cce942](https://github.com/sitkoru/php-docker/commit/7cce94255f7160dd87b691391910e08d9e9bac09))

# [1.22.0](https://github.com/sitkoru/php-docker/compare/v1.21.0...v1.22.0) (2021-11-16)


### Features

* **php:** PHP 7.3.32 ([19d30c0](https://github.com/sitkoru/php-docker/commit/19d30c0749c95fcd9a080af39d10f8997ee96ca8))

# [1.21.0](https://github.com/sitkoru/php-docker/compare/v1.20.0...v1.21.0) (2021-10-25)


### Bug Fixes

* **nginx:** fix mapping https ([7793619](https://github.com/sitkoru/php-docker/commit/77936195860591fd4379ae2f31b058f0d9dbefaf))


### Features

* **php:** PHP 7.4.25 ([ad1f1a5](https://github.com/sitkoru/php-docker/commit/ad1f1a58c13835b91707c2c4a9d44812d192167a))
* **php:** PHP 8.0.12 ([bcf7127](https://github.com/sitkoru/php-docker/commit/bcf7127c2f0bc50abb9f32df4e63a2e4a0ec8806))

# [1.20.0](https://github.com/sitkoru/php-docker/compare/v1.19.0...v1.20.0) (2021-10-18)


### Bug Fixes

* **certs:** run apt upgrade to install latests certs ([99a2fd6](https://github.com/sitkoru/php-docker/commit/99a2fd69ff656c3c2dd0b4dd6ad35d744f04f50b))


### Features

* **nginx:** map scheme and port from proxy to fastcgi ([4c7f173](https://github.com/sitkoru/php-docker/commit/4c7f1736372d73e20c054a1ed7b254a485c94ee2))

# [1.19.0](https://github.com/sitkoru/php-docker/compare/v1.18.0...v1.19.0) (2021-09-24)


### Features

* **nginx:** split php include to allow adding fastcgi_options ([a70092a](https://github.com/sitkoru/php-docker/commit/a70092a8af10c0aece5398741f5f1196a74f5b4c))

# [1.18.0](https://github.com/sitkoru/php-docker/compare/v1.17.0...v1.18.0) (2021-09-24)


### Features

* **php:** 7.3.31, 7.4.24, 8.0.11 ([7ae7186](https://github.com/sitkoru/php-docker/commit/7ae7186372d212c2085ed4253de85d5e413aa187))

# [1.17.0](https://github.com/sitkoru/php-docker/compare/v1.16.2...v1.17.0) (2021-09-22)


### Features

* **nginx:** replace global.conf with nginx.conf ([9351b52](https://github.com/sitkoru/php-docker/commit/9351b52fa769630e5bbade942fc7c87dd784b71b))

## [1.16.2](https://github.com/sitkoru/php-docker/compare/v1.16.1...v1.16.2) (2021-09-20)


### Bug Fixes

* **extensions:** fix php74 version pattern ([320d003](https://github.com/sitkoru/php-docker/commit/320d0035088575c05b53c78555d8568d785e4a72))
* **gd:** fix configure gd for all versions < 8 ([4f37783](https://github.com/sitkoru/php-docker/commit/4f3778306fce75f7dfffc51f5b702cd9668ea6ec))
* **gd:** fix gd installation for php7.4 ([4e28f45](https://github.com/sitkoru/php-docker/commit/4e28f452e72e045b680bc8f53244ef26d5765f16))

## [1.16.1](https://github.com/sitkoru/php-docker/compare/v1.16.0...v1.16.1) (2021-09-14)


### Bug Fixes

* **nginx:** remove duplicate setting from global config ([e298646](https://github.com/sitkoru/php-docker/commit/e2986469ce7567d3c09d2ac842a87511cee70058))

# [1.16.0](https://github.com/sitkoru/php-docker/compare/v1.15.2...v1.16.0) (2021-09-13)


### Features

* **nginx:** add default nginx settings ([e64e9ab](https://github.com/sitkoru/php-docker/commit/e64e9ab295de31b21edc2e1be32ac4012b4e6d66))

## [1.15.2](https://github.com/sitkoru/php-docker/compare/v1.15.1...v1.15.2) (2021-09-13)


### Bug Fixes

* **nginx:** remove all default sites ([4c032cf](https://github.com/sitkoru/php-docker/commit/4c032cf4b1b270e4f9e0485c8300bd9cb6524b08))

## [1.15.1](https://github.com/sitkoru/php-docker/compare/v1.15.0...v1.15.1) (2021-09-10)


### Bug Fixes

* **ci:** pass version on every step of ci workflow ([344947b](https://github.com/sitkoru/php-docker/commit/344947b0f2e45d9ff027273c4cd3dc602314f3bf))
* **ci:** upd setup-buildx-action ([a7e445e](https://github.com/sitkoru/php-docker/commit/a7e445e19bab7067dfcc24a9c32ed5f577b033cb))
* **dev:** fix installing xdebug and ast ([eafa46e](https://github.com/sitkoru/php-docker/commit/eafa46ec0c6ebdd9a31adab31595d0694a8f1756))
* **dev:** syntax fix in install_dev script ([5a36e7d](https://github.com/sitkoru/php-docker/commit/5a36e7d5c3cc02ecb2b6097416e7a6175b6490dc))
* **dev:** use install_dev script in Dockerfile ([d7016b3](https://github.com/sitkoru/php-docker/commit/d7016b35c67d14e49690d6dde15b06cd9ea1ff89))
* **php5:** install old xdebug, don't install ast ([ad7f167](https://github.com/sitkoru/php-docker/commit/ad7f1671059f59453dd03d601313feab22b95ad4))

# [1.15.0](https://github.com/sitkoru/php-docker/compare/v1.14.0...v1.15.0) (2021-09-10)


### Bug Fixes

* **files:** fix deleting files ([bb2defa](https://github.com/sitkoru/php-docker/commit/bb2defa10f33a57f003c6b6c3f3dd79190139b31))
* **nginx:** fix cleaning nginx default configs ([9a770ae](https://github.com/sitkoru/php-docker/commit/9a770aee2485aa3ff512221f6f34529873ff80db))


### Features

* **nginx:** don't build nginx, install from repo ([3ca2c87](https://github.com/sitkoru/php-docker/commit/3ca2c8739878bf8d25ed2a603f9a24721919e8fe))
* **php5:** add php 5.6.40 ([f5cc6ea](https://github.com/sitkoru/php-docker/commit/f5cc6ea205e938c0eed89710b0d0b46c23769e7a))

# [1.14.0](https://github.com/sitkoru/php-docker/compare/v1.13.0...v1.14.0) (2021-09-10)


### Features

* **ssh:** make nginx with ssh image ([d2a715b](https://github.com/sitkoru/php-docker/commit/d2a715b8d4706c4d669adc78f55981db2993f862))

# [1.13.0](https://github.com/sitkoru/php-docker/compare/v1.12.0...v1.13.0) (2021-08-30)


### Bug Fixes

* **ci:** auth in ghcr ([2e63351](https://github.com/sitkoru/php-docker/commit/2e63351e804b72b8f58c08cf735decefb49eb6c4))
* **ci:** default version number pattern with v ([8d4af1b](https://github.com/sitkoru/php-docker/commit/8d4af1b1b757a9ad2e0f0150befa24a179ce1839))
* **ci:** don't need custom container for release action ([d424841](https://github.com/sitkoru/php-docker/commit/d42484172f54d24561203c092c3471b0dd7ffa99))
* **ci:** run release stop on public runner ([d695b29](https://github.com/sitkoru/php-docker/commit/d695b2941dfb6d737489b54ea3a64c5164c6f8b2))


### Features

* **ci:** semantic-release ([72522e2](https://github.com/sitkoru/php-docker/commit/72522e2acf67fbf9658b2a6bc17293c9131a5434))
* **php:** php 7.3.30, 7.4.23 and 8.0.10 ([0aa4472](https://github.com/sitkoru/php-docker/commit/0aa4472e35afea4f1bb7600135130f246369fafa))
