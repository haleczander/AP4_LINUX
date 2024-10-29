#!/bin/bash

function resetArchive() {
    if [ ! -d $OUTPUT ]; then
        mkdir $USER_DIR;
    fi

    if [ -f $ARCHIVE ];then
    mv $ARCHIVE $ARCHIVE_OLD;
    fi
    touch $ARCHIVE;
}

function resetOutput() {
    if [ -d $OUTPUT ];then
        rm -rf $OUTPUT;
    fi
    mkdir -p $OUTPUT;
}

function reuploadFileIo() {
    echo "Reuploading to File.IO";

    local curled=$( curl -X POST "https://file.io/" \
        -H "Authorization: Bearer $API_KEY" \
        -F "file=@$ARCHIVE" );
    local file_url=$( echo $curled | grep -Po '"link":.*?[^\\]",' | cut -d '"' -f 4 );

    sed -i "s|$ARCHIVE_LINK|$file_url|g" $FILE_HISTORY;
}

function saveDiscord() {
    echo "Saving to discord";
    local MESSAGE=$( date +"%d/%m/%y %H:%M" );
    local curled=$( curl -F "payload_json={\"username\": \"$BOT_NAME\", \"content\": \"$MESSAGE\"}" -F "file1=@$ARCHIVE" $WEBHOOK );
    echo $curled > curl.json;
    local file_url=$( echo $curled | grep -Po '"url":.*?[^\\]",' | cut -d '"' -f 4 );
    echo $( date +%s )";""$file_url" >> $FILE_HISTORY;
}

function archive() {
    resetArchive;

    while IFS= read -r line; do
        echo "Archiving " $line;
        bash $ARCHIVER $line $ARCHIVE;
    done < $TO_COMPRESS_FILE;

    if [ -f $ARCHIVE_OLD ] && [ "$(diff -U 0 $ARCHIVE $ARCHIVE_OLD | grep ^@ | wc -l)" -eq 0 ]; then
        if $UPLOAD_FLAG; then
            echo "Aucune différence avec la dernière archive, annulation de l'upload";
        fi
        UPLOAD_FLAG=false;
    fi

}


function extract() {
    resetOutput;
    echo "Extracting " $ARCHIVE;
    bash $EXTRACTER $ARCHIVE $OUTPUT;
}

function findArchiveLink() {
    local currentTimestamp;
    echo Downloading closest anterior archive to $( date -d "@$DATE" +"%Y-%m-%d %H:%M" );
    while read -r line; do
        currentTimestamp=$( echo $line | cut -d ";" -f 1 );
        if [ $currentTimestamp -le "$DATE" ]; then
            ARCHIVE_TIMESTAMP=$currentTimestamp;
            ARCHIVE_LINK=$( echo $line | cut -d ";" -f 2 );
        fi
    done < $FILE_HISTORY;
}

function upload() {
    bash $UPLOADER $ARCHIVE $FILE_HISTORY;
}


function download() {
    findArchiveLink;
    if [ -n "$ARCHIVE_LINK" ]; then
        echo "Extracting archive from" $( date -d "@$ARCHIVE_TIMESTAMP" +"%Y-%m-%d %H:%M" );
        bash $DOWNLOADER $ARCHIVE_DL $ARCHIVE_LINK $FILE_HISTORY;
        ARCHIVE=$ARCHIVE_DL;
        extract;
    else
        echo "No record found."
    fi
}

function show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -a, --archive           Archive the specified files in ./.tocompress"
    echo "  -d, --download          Downloads the last uploaded archive, or the last from the specified date with format \"yyyy-mm-dd hh:mm\""
    echo "  -e, --extract           Extract files from  ./archive"
    echo "  -h, --help              Display this help message."
    echo "  -u, --upload            Upload the archived files after archiving"
}

source $( dirname $(readlink -f $0 ) )/config.sh

ARCHIVE_FLAG=false
UPLOAD_FLAG=false

while [ $# -gt 0 ]; do
    case $1 in
        -a | --archive )
            ARCHIVE_FLAG=true
            ;;
        -u | --upload )
            UPLOAD_FLAG=true
            ;;
        -e | --extract )
            extract
            exit 0
            ;;
        -d | --download )
            DATE=$( [ -n "$2" ] && date -d "$2" +"%s" || date +"%s" );
            download
            exit 0
            ;;
        -h | --help )
            show_help
            exit 0
            ;;
        * )
            echo "Error: Invalid option '$1'"
            show_help
            exit 1
    esac
    shift
done

if $ARCHIVE_FLAG || [ $# -eq 0 ]; then
    archive
    if $UPLOAD_FLAG; then
        upload
    fi
fi