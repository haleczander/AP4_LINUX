PROGRAM_NAME=mon_super_archiver
SCRIPT_DIR=$( dirname $(readlink -f $0 ) )
USER_DIR=~/$PROGRAM_NAME
USER_BIN=/usr/bin/$PROGRAM_NAME

ARCHIVER=$SCRIPT_DIR/archiver.sh
EXTRACTER=$SCRIPT_DIR/extracter.sh
UPLOADER=$SCRIPT_DIR/uploader.sh
DOWNLOADER=$SCRIPT_DIR/downloader.sh
DISCORD=$SCRIPT_DIR/discord.sh

TO_COMPRESS_FILE=$USER_BIN/.tocompress
ARCHIVE=$USER_DIR/archive
ARCHIVE_OLD=$ARCHIVE"_OLD"
OUTPUT=$USER_DIR/output
FILE_HISTORY=$USER_DIR/file_history
ARCHIVE_DL=$ARCHIVE"_DL"
API_KEY_FILE=$SCRIPT_DIR/file.io.key
API_KEY=$( cat $API_KEY_FILE )
WEBHOOK="https://discord.com/api/webhooks/1288862525538177046/n7nL2-P8lf0YEqpGgU6Hs8b1mTpz0oEPlelZqoS0tookcHSoDj9jxVDxZcg4_vtb8DxP"
BOT_NAME="Super Archiver"

POUBELLE="/dev/null";
TAILLE_NOM_ENC=4;
TAILLE_FICHIER_ENC=16;