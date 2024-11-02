#!/bin/bash

PROGRAM_NAME=mon_super_archiver

SCRIPT_DIR=$( dirname $(readlink -f $0 ) )

INSTALL_DIR=/bin/$PROGRAM_NAME
SERVICES_DIR=/etc/systemd/system

echo "Installation de $PROGRAM_NAME"
# Copie des scripts
echo "Copie des scripts vers $INSTALL_DIR"
if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf $INSTALL_DIR
fi
sudo mkdir $INSTALL_DIR

sudo cp $SCRIPT_DIR/sources/* $INSTALL_DIR

echo "Configuration des droits"
sudo chmod 777 $INSTALL_DIR**
sudo chmod a+x $INSTALL_DIR/*.sh
touch $INSTALL_DIR/.tocompress
sudo chmod a+w $INSTALL_DIR/.tocompress



echo "Installation des dépendances"
# Installation de curl
sudo apt-get update > /dev/null && apt-get -y install curl > /dev/null

echo "Configuration du service"
# Démarrage du service
if pidof systemd > /dev/null; then
    # Copie des fichiers de service
    sudo cp $SCRIPT_DIR/service/* $SERVICES_DIR
    sudo systemctl daemon-reload
    sudo systemctl enable $PROGRAM_NAME.service $PROGRAM_NAME.timer
    # Démarrage du service
    sudo systemctl start $PROGRAM_NAME.service $PROGRAM_NAME.timer
else
    echo "Systemd n'est pas disponible. Le service ne peut pas être démarré."
fi

echo "Installation terminée"


