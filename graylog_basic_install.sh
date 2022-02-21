#!/bin/bash
#
#Nom		: Script d'installation de Graylog
#Description	: Installe et configure le serveur de log
#Auteurs	: Mathis Thouvenin, Lyronn Levy, Simon Vener
#Version	: 1.0
#Date		: 20/02/2022
#
#A la fin de ce script, lancer un reboot et le script graylog_after_reboot
#
#affiche les commandes effectuées
#set -x
#
#arrête le script dès qu'une erreur survient
#set -e

function debian_update()
{
	apt update && apt upgrade -y
}

function basic_packets()
{
	apt install sudo vim curl wget tree rsync mlocate screen unzip htop -y
	#installation de gnupg pour mongodb
	apt install gnupg -y
	#installation java
	apt install openjdk-11-jre-headless -y
}

function install_mongodb()
{
	wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
	echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list
	apt update -y
	apt install -y mongodb-org
}

function start_mongodb()
{
	systemctl daemon-reload
	systemctl enable mongod.service
	systemctl restart mongod.service
	systemctl --type=service --state=active | grep mongod
}

function install_elasticsearch()
{
	wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
	echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
	apt update && sudo apt install elasticsearch-oss

	#ajoute le nom du cluster
	sed -i "s/#cluster.name: my-application/cluster.name: graylog/" /etc/elasticsearch/elasticsearch.yml

	#un index ne sera pas créé automatiquement
	echo "action.auto_create_index: false" >> /etc/elasticsearch/elasticsearch.yml

	#modification des paramètres résau de elasticsearch
	sed -i "s/#network.host: 192.168.0.1/network.host: 127.0.0.1/" /etc/elasticsearch/elasticsearch.yml

	sed -i "s/#http.port: 9200/http.port: 9200/" /etc/elasticsearch/elasticsearch.yml

	#modification de la taille de la heap: Xms, taille minimale, Xmx taille maximale
	#les deux valeurs doivent être identiques
	#modifier si l'erreur "There is insufficient memory for the Javva Runtinme Environment to continue" survient
	#sed -i "s/-Xms1g/-Xms2g/" /etc/elasticsearch/jvm.options
	#sed -i "s/-Xmx1g/-Xmx2g/" /etc/elasticsearch/jvm.options

	#pallier à l'erreur timeout de elasticsearch
	#elasticsearch provoque une erreur si le service ne démarre pas après 90s
	#il faut augementer la durée de démarrage
	#creation d'un dossier de gestion de durée dans systemd
	#mkdir /etc/systemd/system/elasticsearch.service.d

	#definit la nouvelle duree à 180s
	#echo -e "[Service]\nTimeoutStartSec=180" | sudo tee /etc/systemd/system/elasticsearch.service.d/startup-timeout.conf	

	#redemarre le service
	#systemctl daemon-reload

	#affiche si la nouvelle duree d'attente a été prise en compte
	#systemctl show elasticsearch | grep ^Timeout
}

function start_elasticsearch()
{
	systemctl daemon-reload
	systemctl enable elasticsearch.service
	systemctl restart elasticsearch.service
	systemctl restart elasticsearch.service
}

function install_graylog()
{
	wget https://packages.graylog2.org/repo/packages/graylog-4.2-repository_latest.deb

	#utilisation du gestionnaire de paquet dpkg pour installer le paquet avec l'option -i
	dpkg -i graylog-4.2-repository_latest.deb
	apt update -y
	apt install graylog-server -y

	#decommente le nom du user root
	sed -i "s/#root_username = admin/root_username = admin/" /etc/graylog/server/server.conf

	#créer le root_password_sha2
	root_password=$(echo -n "admin" | shasum -a 256 | cut -d" " -f1)

	#simule la touche entrée
	echo -e "\n"

	#retire les 6 premiers caractères de la commande précédente
	#donc on retire 'admin '
	#root_password=${root_password:6}

	#ajoute le root_password hashé dans /etc/graylog/server/server.conf
	sed -i "s/root_password_sha2 =/root_password_sha2 = $root_password/" /etc/graylog/server/server.conf
	
	#installation du generateur de mdp pwgen
	apt install pwgen

	#generation d'un mdp hashé avec pwgen
	password_secret=$(pwgen -N 1 -s 96)

	#ajoute le mdp généré précédemment dans le ficher /etc/graylog/server/server.conf
	sed -i "s/password_secret =/password_secret = $password_secret/" /etc/graylog/server/server.conf

	#ajoute l'adresse IP du serveur
	sed -i "s/#http_bind_address = 127.0.0.1:9000/http_bind_address = 192.168.1.20:9000/" /etc/graylog/server/server.conf

}

function start_graylog()
{
	systemctl daemon-reload
	systemctl enable graylog-server.service
	systemctl start graylog-server.service
	systemctl --type=service --state=active | grep graylog
}

clear

echo "Mise à jour du système"
debian_update

echo "Installation de paquets Debian" 
basic_packets

echo "Installation de MongoDB"
install_mongodb

echo "Lancement de MongoDB"
start_mongodb

echo "Installation de ElasticSearch"
install_elasticsearch

echo "Lancement de ElasticSearch"
start_elasticsearch

echo "Installation de Graylog"
install_graylog

echo "Lancement de Graylog"
start_graylog

echo "Redémarrer MongoDB, ElasticSearch et Graylog"
start_mongodb
start_elasticsearch
start_graylog

