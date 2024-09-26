# !/bin/bash

function resetArchive() {
    if [ -f $ARCHIVE ];then
    rm $ARCHIVE;
    fi
    touch $ARCHIVE;
}

function resetOutput() {
    if [ -d $OUTPUT ];then
        exit 1;
    fi
    mkdir -p $OUTPUT;
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

}

function extract() {
    resetOutput;
    echo "Extracting " $ARCHIVE;
    bash $EXTRACTER $ARCHIVE $OUTPUT;
}

SCRIPT_DIR=$( dirname $(readlink -f $0 ) )
ARCHIVER=$SCRIPT_DIR/archiver.sh
EXTRACTER=$SCRIPT_DIR/extracter.sh
TO_COMPRESS_FILE=$SCRIPT_DIR/.tocompress
ARCHIVE=$SCRIPT_DIR/archive
OUTPUT=$SCRIPT_DIR/output

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
