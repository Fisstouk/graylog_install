# graylog_install

Ce script utilise la [documentation de Graylog](https://docs.graylog.org/docs/debian) afin d'installer le logiciel Graylog sur Debian 10.
Pour ce faire, lancez d'abord le script graylog_basic_install.sh, redémarrez le système et lancez le script graylog_after_reboot.sh.

L'objectif est de se passer du script graylog_after_reboot.sh et d'automatiser le démarrage de Graylog quand le système Debian démarre.

Le script graylog_config.sh a pour but de configurer les éléments de base afin de faire fonctionner la collecte, le stockage et l'analyse des logs.
