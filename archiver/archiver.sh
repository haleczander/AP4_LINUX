#!/bin/bash

source $( dirname $(readlink -f $0 ) )/config.sh

DIR=$( echo $1 | tr -d '\r' );
ARCHIVE=$2;

find $DIR -type f -printf '%p\0' | while IFS= read -r -d '' fichier; do
    b64=$(base64 -w0 "$fichier" );
    printf "%0"$TAILLE_NOM_ENC"d" ${#fichier} >> $ARCHIVE;
    printf "$fichier" >> $ARCHIVE;
    printf "%0"$TAILLE_FICHIER_ENC"d" ${#b64} >> $ARCHIVE;
    echo $b64 >> $ARCHIVE 2> $POUBELLE;
done
