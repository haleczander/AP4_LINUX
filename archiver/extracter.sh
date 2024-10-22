#!/bin/bash

source $( dirname $(readlink -f $0 ) )/config.sh

ARCHIVE=$1
OUTPUT=$2;

BACKUP_IFS=$IFS;
IFS=$'\n'

while read line; do
    taille_nom=$( expr ${line:0:$TAILLE_NOM_ENC} + 0 );
    end_nom=$( expr $TAILLE_NOM_ENC + $taille_nom );
    nom="${line:$TAILLE_NOM_ENC:$taille_nom}";
    echo $nom;
    end_taille_fichier=$( expr $end_nom + $TAILLE_FICHIER_ENC );        
    taille_fichier=$( expr ${line:$end_nom:$TAILLE_FICHIER_ENC} + 0);
    end_fichier=$( expr $end_taille_fichier + $taille_fichier );

    fichier=${line:$end_taille_fichier:$taille_fichier};
    mkdir -p $( dirname "$OUTPUT/$nom" );
    echo $fichier | base64 -d > "$OUTPUT/$nom";

done < $ARCHIVE;
IFS=$BACKUP_IFS;

# remettre if sr espace