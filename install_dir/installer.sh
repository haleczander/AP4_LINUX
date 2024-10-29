#!/bin/bash

PROGRAM_NAME=mon_super_archiver

SCRIPT_DIR=$( dirname $(readlink -f $0 ) )

INSTALL_DIR=/bin/$PROGRAM_NAME
USR_BIN=/usr$INSTALL_DIR
SERVICES_DIR=/etc/systemd/system

# Installation des dépendances
sudo apt-get install -y curl dos2unix
sudo dos2unix **

# Copie des scripts
if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf $INSTALL_DIR
fi
sudo mkdir $INSTALL_DIR

sudo cp $SCRIPT_DIR/sources/* $INSTALL_DIR
sudo chmod 777 $INSTALL_DIR**
sudo chmod a+x $INSTALL_DIR/*.sh
touch $USR_BIN/.tocompress
sudo chmod a+w $USR_BIN/.tocompress
ls -la $INSTALL_DIR

# Copie des fichiers de service
sudo cp $SCRIPT_DIR/service/* $SERVICES_DIR


# Démarrage du service
if pidof systemd > /dev/null; then
    # Relance des services
    sudo systemctl daemon-reload
    # Ajout de notre service au démarrage
    sudo systemctl enable $PROGRAM_NAME.service
    # Démarrage
    sudo systemctl start $PROGRAM_NAME.service $PROGRAM_NAME.timer
else
    # Démarrage du service avec init.d
    sudo cp $SCRIPT_DIR/service/$PROGRAM_NAME /etc/init.d/
    sudo update-rc.d $PROGRAM_NAME defaults
    sudo /etc/init.d/$PROGRAM_NAME start
fi


