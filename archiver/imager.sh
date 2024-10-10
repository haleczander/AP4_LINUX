
function imagify() {
    nb=$( cat archiver/archive | wc -c );
    pixels=$( expr $(expr $nb / 6 ) + 1 );
    cols=$( awk "BEGIN { print sqrt($pixels) }");
    echo $nb $pixels ${cols%.*};

}

imagify