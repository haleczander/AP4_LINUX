#!/bin/bash

source $( dirname $(readlink -f $0 ) )/config.sh

FILE=$1
FILE_URL=$2
FILE_HISTORY=$3

function get() {
    curl -o $FILE $FILE_URL;
}

function reupload() {
    bash $UPLOADER $FILE $FILE_HISTORY $FILE_URL;
}

function show_help() {
    echo "Usage: $0 <file> <file_url> <file_history>"
    echo ""
    echo "Options:"
    echo "  -h, --help               Display this help message"
    echo ""
    echo "Arguments:"
    echo "  file                     The file to download or reupload"
    echo "  file_url                 The URL of the file to download"
    echo "  file_history             The file history for reuploading"
}

while [ $# -gt 0 ]; do
    case $1 in
        -h | --help )
            show_help;
            exit 0;
            ;;
        * )
            if [[ ! $# -eq 3 ]]; then
                show_help;
                exit 1;
            fi
                get;
                reupload;
                exit 0;
            ;;
    esac
done

