#!bin/bash
#
#Nom		: Script d'installation de Graylog
#Description	: Installe et configure le serveur de log
#Auteurs	: Mathis Thouvenin, Lyronn Levy, Simon Vener
#Version	: 0.1
#Date		: 10/02/2022
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
	apt install graylog-server

	#créer le root_password_sha2
	echo 'aze\!123' && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1
}

function start_graylog()
{
	systemctl daemon-reload
	systemctl enable graylog-server.service
	systemctl start graylog-server.service
	systemctl --type=service --state=active | grep graylog
}


echo('Mise à jour du système')
debian_update

echo('Installation de paquets Debian')
basic_packets

echo('Installation de MongoDB')
install_mongodb

echo('Lancement de MongoDB')
start_mongodb

echo('Installation de ElasticSearch')
install_elasticsearch

echo('Lancement de ElasticSearch')
start_elasticsearch

echo('Installation de Graylog')
install_graylog
