file=/tmp/hosts
SOURCE_STRING="dev.s3bucket.mrshmc.com"
# REPLACEMENT_TEXT_STRING="dev.s3bucket.mrshmc.com"

ip=`nslookup $SOURCE_STRING | grep -m2 Address | tail -n1 | cut -d : -f 2`
REPLACEMENT_TEXT_STRING="$ip   $SOURCE_STRING"
sed -i "/$SOURCE_STRING/c $REPLACEMENT_TEXT_STRING" $file
