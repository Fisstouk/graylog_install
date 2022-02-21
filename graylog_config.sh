#!/bin/bash
#
#Date:		21/02/2022
#

function rsyslog_graylog()
{
	#envoie les données de l'hôte Linux avec syslog vers graylog
	#les données envoyées ne sont pas chiffrées

	echo "#graylog UDP" >> /etc/rsyslog.conf
	echo "*.*@yourgraylog.example.org:514;RSYSLOG_SyslogProtocol23Format" >> /etc/rsyslog.conf

	echo "#graylog TCP" >> /etc/rsyslog.conf
	echo "*.*@@yourgraylog.example.org:514;RSYSLOG_SyslogProtocol23Format" >> /etc/rsyslog.conf
}

echo "Configuration de rsyslog pour envoyer les données vers Graylog"
rsyslog_graylog

