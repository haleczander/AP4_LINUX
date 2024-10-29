#!/bin/bash

FILE=$1
FILE_HISTORY=$2
OLD_URL=$3

source $( dirname $(readlink -f $0 ) )/config.sh

function post() {
    CURL=$( curl -X POST "https://file.io/" \
        -H "Authorization: Bearer $API_KEY" \
        -F "file=@$FILE" );
    FILE_URL=$( echo $CURL | grep -Po '"link":.*?[^\\]",' | cut -d '"' -f 4 );
}

function upload() {
    echo "Uploading to File.IO";
    post;
    echo $( date +%s )";""$FILE_URL" >> $FILE_HISTORY;    
}

function reupload() {
    echo "Re-uploading to File.IO";
    post;
    sed -i "s|$OLD_URL|$FILE_URL|g" $FILE_HISTORY;
}

function show_help() {
    echo "Usage: $0 <file> <file_history> [old_url]"
    echo "Arguments:"
    echo "  file          - The file to upload"
    echo "  file_history  - The file to store the upload history"
    echo "  old_url       - (Optional) The old URL to replace in the history file"
    exit 1
}

while [ $# -gt 0 ]; do
    case $1 in
        -h | --help )
            show_help
            exit 0
            ;;
        * )
            if [[ $# -lt 2 || $# -gt 3 ]]; then
                show_help;
                exit 1;
            fi
            if [ $# -eq 2 ]; then
                upload
            elif [ $# -eq 3 ]; then
                reupload
            fi
            exit 0;
    esac
done




