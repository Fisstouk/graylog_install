#!/bin/bash
#
#lancer le script graylog_basic_install.sh en amont
#
#relance le service graylog

systemctl daemon-reload
systemctl enable graylog-server.service
systemctl start graylog-server.service
systemctl --type=service --state=active | grep graylog
