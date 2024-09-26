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

function saveDiscord() {
    echo "Saving to discord";
    MESSAGE=$( date +"%d/%m/%y %H:%M" );

    file_url=$( curl \
    -F "payload_json={\"username\": \"$BOT_NAME\", \"content\": \"$MESSAGE\"}" \
    -F "file1=@$ARCHIVE" \
    $WEBHOOK | grep -Po '"url":.*?[^\\]",' | cut -d '"' -f 4 );
    echo $( date +%s )";""$file_url" >> $FILE_HISTORY;
}

# function imagify() {
#     nb=$( cat $ARCHIVE | wc -c );
#     pixels=$( expr $(expr $nb / 6 ) + 1 );
#     echo $nb $pixels;
#     cols=$( awk "BEGIN { print sqrt($pixels) }");
# }

function archive() {
    resetArchive;

    while IFS= read -r line; do
        echo "Archiving " $line;
        bash $ARCHIVER $line $ARCHIVE;
    done < $TO_COMPRESS_FILE;

    if [ -f $ARCHIVE_OLD ];then
        diffs=$( diff -U 0 $ARCHIVE $ARCHIVE_OLD | grep ^@ | wc -l );
        if [ "$diffs" -gt 0 ]; then
            saveDiscord;
        fi
    else
        saveDiscord;
    fi

}

function extract() {
    resetOutput;
    echo "Extracting " $ARCHIVE;
    bash $EXTRACTER $ARCHIVE $OUTPUT;
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

WEBHOOK="https://discord.com/api/webhooks/1288862525538177046/n7nL2-P8lf0YEqpGgU6Hs8b1mTpz0oEPlelZqoS0tookcHSoDj9jxVDxZcg4_vtb8DxP"
BOT_NAME="Super Archiver"

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -a, --archive      Archive the specified files in ./.tocompress"
echo "  -e, --extract          Extract files from  ./archive"
echo "  --help                 Display this help message."
}

while [ $# -gt 0 ]; do
    case $1 in
        -a | --archive )
            archive
            shift
            exit 0
            ;;
        -e | --extract )
            extract
            shift
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
