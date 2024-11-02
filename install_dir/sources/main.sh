#!/bin/bash

function resetArchive() {
    echo "Resetting archive";
    if [ ! -d $USER_DIR ]; then
        mkdir $USER_DIR;
    fi

    if [ -f $ARCHIVE ];then
    mv $ARCHIVE $ARCHIVE_OLD;
    fi
    touch $ARCHIVE;
    echo "Resetting archive done";
}

function resetOutput() {
    echo "Resetting output";
    if [ -d $OUTPUT ];then
        rm -rf $OUTPUT;
    fi
    mkdir -p $OUTPUT;
    echo "Resetting output done";
}

function archive() {
    echo "Archiving files";
    resetArchive;

    while IFS= read -r line; do
        bash $ARCHIVER $line $ARCHIVE;
    done < $TO_COMPRESS_FILE;

    if [ ! $FORCE_FLAG ] && [ -f $ARCHIVE_OLD ] && [ "$(diff -U 0 $ARCHIVE $ARCHIVE_OLD | grep ^@ | wc -l)" -eq 0 ]; then
        if $UPLOAD_FLAG; then
            echo "Aucune différence avec la dernière archive, annulation de l'upload";
        fi
        UPLOAD_FLAG=false;
    fi
    echo "Archiving done";

}


function extract() {
    echo "Extracting files";
    resetOutput;
    echo "Extracting " $ARCHIVE;
    bash $EXTRACTER $ARCHIVE $OUTPUT;
    echo "Extracting done";
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
    echo "Uploading archive";
    bash $UPLOADER $ARCHIVE $FILE_HISTORY;
    echo "Uploading done";
}

function discordUpload() {
    echo "Uploading to discord";
    bash $DISCORD $ARCHIVE;
    echo "Uploading to discord done";
}


function download() {
    echo "Downloading archive";
    findArchiveLink;
    if [ -n "$ARCHIVE_LINK" ]; then
        echo "Extracting archive from" $( date -d "@$ARCHIVE_TIMESTAMP" +"%Y-%m-%d %H:%M" );
        bash $DOWNLOADER $ARCHIVE_DL $ARCHIVE_LINK $FILE_HISTORY;
        ARCHIVE=$ARCHIVE_DL;
        extract;
    else
        echo "No record found."
    fi
    echo "Downloading done";
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
    echo "  -s, --discord           Upload the archived files to discord after archiving"
    echo "  -f, --force             Force the upload even if the archive is the same as the last one"
}

source $( dirname $(readlink -f $0 ) )/config.sh

ARCHIVE_FLAG=false
UPLOAD_FLAG=false
DISCORD_FLAG=false
FORCE_FLAG=false

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
        -s | --discord )
            DISCORD_FLAG=true
            ;;
        -f | --force )
            FORCE_FLAG=true
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
    if $DISCORD_FLAG; then
        discordUpload
    fi

fi