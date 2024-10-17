#!/bin/bash

PROGRAM_NAME=mon_super_archiver

SCRIPT_DIR=$( dirname $(readlink -f $0 ) )

INSTALL_DIR=/bin/$PROGRAM_NAME
SERVICES_DIR=/etc/systemd/system

# Copie des scripts
if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf $INSTALL_DIR
fi
sudo mkdir $INSTALL_DIR

sudo cp $SCRIPT_DIR/sources/* $INSTALL_DIR
sudo chmod 777 $INSTALL_DIR**
sudo chmod a+x $INSTALL_DIR/*.sh
touch $INSTALL_DIR/.tocompress
sudo chmod a+w $INSTALL_DIR/.tocompress
ls -la $INSTALL_DIR

# Copie des fichiers de service
sudo cp $SCRIPT_DIR/service/* $SERVICES_DIR


# Installation de curl
sudo apt-get install curl

# Démarrage du service
if pidof systemd > /dev/null; then
    # Démarrage du service
    sudo systemctl start $PROGRAM_NAME.service $PROGRAM_NAME.timer
else
    echo "Systemd n'est pas disponible. Le service ne peut pas être démarré."
fi


