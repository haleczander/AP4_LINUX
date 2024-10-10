# !/bin/bash

POUBELLE="/dev/null";
TAILLE_NOM_ENC=4;
TAILLE_FICHIER_ENC=16;

DIR=$( echo $1 | tr -d '\r' );
ARCHIVE=$2;

find $DIR -type f -printf '%p\0' | while IFS= read -r -d '' fichier; do
    b64=$(base64 -w0 "$fichier" );
    printf "%0"$TAILLE_NOM_ENC"d" ${#fichier} >> $ARCHIVE;
    printf "$fichier" >> $ARCHIVE;
    printf "%0"$TAILLE_FICHIER_ENC"d" ${#b64} >> $ARCHIVE;
    echo $b64 >> $ARCHIVE 2> $POUBELLE;
done
