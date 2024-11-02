#!/bin/bash

source $( dirname $(readlink -f $0 ) )/config.sh

TO_UPLOAD=$1

function discordUpload() {
    local MESSAGE=$( date +"%d/%m/%y %H:%M" );
    local curled=$( curl -F "payload_json={\"username\": \"$BOT_NAME\", \"content\": \"$MESSAGE\"}" -F "file1=@$TO_UPLOAD" $WEBHOOK );
    local file_url=$( echo $curled | grep -Po '"url":.*?[^\\]",' | cut -d '"' -f 4 );
    echo "Uploaded to discord: $file_url";
}

function show_help() {
    echo "Usage: $0 <file>"
    echo "Arguments:"
    echo "  file          - The file to upload"
    exit 1
}

while [ $# -gt 0 ]; do
    case $1 in
        -h | --help )
            show_help
            exit 0
            ;;
        * )
            if [ $# -ne 1 ]; then
                show_help;
                exit 1;
            fi
            discordUpload
            exit 0;
    esac
done

