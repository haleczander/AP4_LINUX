# !/bin/bash

function resetArchive() {
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

function saveFileIo() {
    echo "Saving to File.IO";
    
    local curled=$( curl -X POST "https://file.io/" \
        -H "Authorization: Bearer $API_KEY" \
        -F "file=@$ARCHIVE" );
    local file_url=$( echo $curled | grep -Po '"link":.*?[^\\]",' | cut -d '"' -f 4 );
    echo $( date +%s )";""$file_url" >> $FILE_HISTORY;    
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

    if [ -f $ARCHIVE_OLD ];then
        diffs=$( diff -U 0 $ARCHIVE $ARCHIVE_OLD | grep ^@ | wc -l );
        if [ "$diffs" -gt 0 ]; then
            saveFileIo;
            # saveDiscord;
        fi
    else
        saveFileIo;
        # saveDiscord;
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

function download() {
    findArchiveLink;
    if [ -n "$ARCHIVE_LINK" ]; then
        echo "Extracting archive from" $( date -d "@$ARCHIVE_TIMESTAMP" +"%Y-%m-%d %H:%M" );
        curl $lastFile > $ARCHIVE_DL;
        ARCHIVE=$ARCHIVE_DL;
        extract;
        reuploadFileIo;
    else
        echo "No record found."
    fi
}

SCRIPT_DIR=$( dirname $(readlink -f $0 ) )
ARCHIVER=$SCRIPT_DIR/archiver.sh
EXTRACTER=$SCRIPT_DIR/extracter.sh
DISCORD=$SCRIPT_DIR/discord.sh
TO_COMPRESS_FILE=$SCRIPT_DIR/.tocompress
ARCHIVE=$SCRIPT_DIR/archive
ARCHIVE_OLD=$ARCHIVE"_OLD"
OUTPUT=$SCRIPT_DIR/output
FILE_HISTORY=$SCRIPT_DIR/file_history
ARCHIVE_DL=$ARCHIVE"_DL"
API_KEY_FILE=$SCRIPT_DIR/file.io.key
API_KEY=$( cat $API_KEY_FILE )

WEBHOOK="https://discord.com/api/webhooks/1288862525538177046/n7nL2-P8lf0YEqpGgU6Hs8b1mTpz0oEPlelZqoS0tookcHSoDj9jxVDxZcg4_vtb8DxP"
BOT_NAME="Super Archiver"

function show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -a, --archive           Archive the specified files in ./.tocompress"
    echo "  -d, --download          Downloads the last uploaded archive, or the last from the specified date with format \"yyyy-mm-dd hh:mm\""
    echo "  -e, --extract           Extract files from  ./archive"
    echo "  --help                  Display this help message."
}

while [ $# -gt 0 ]; do
    case $1 in
        -a | --archive )
            archive
            exit 0
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
        --help )
            show_help
            exit 0
            ;;
        * )
            echo "Error: Invalid option '$1'"
            show_help
            exit 1
    esac
done

archive
