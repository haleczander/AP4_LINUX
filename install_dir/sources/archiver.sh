#!/bin/bash

source $( dirname $(readlink -f $0 ) )/config.sh

DIR=$( echo $1 | tr -d '\r' );
ARCHIVE=$2;

function archive() {
    echo "Archiving $DIR to $ARCHIVE";
    find $DIR -type f -printf '%p\0' | while IFS= read -r -d '' fichier; do
        echo "Archiving $fichier";
        b64=$(base64 -w0 "$fichier" );
        printf "%0"$TAILLE_NOM_ENC"d" ${#fichier} >> $ARCHIVE;
        printf "$fichier" >> $ARCHIVE;
        printf "%0"$TAILLE_FICHIER_ENC"d" ${#b64} >> $ARCHIVE;
        echo $b64 >> $ARCHIVE 2> $POUBELLE;
    done
}



function show_help() {
    echo "Usage: $0 <dir> <archive>"
    echo "Arguments:"
    echo "  dir     - The directory to archive"
    echo "  archive - The archive file"
    exit 1
}

if [ $# -ne 2 ]; then
    show_help;
    exit 1;
fi

while [ $# -gt 0 ]; do
    case $1 in
        -h | --help )
            show_help
            exit 0
            ;;
        * )
            archive
            exit 0;
    esac
done

