#! /bin/sh

my_dir="$(dirname "$0")"

xmlstarlet ed --inplace \
	--update	"//Context/@path" --value $CONF_PATH \
        "$my_dir/..//conf/server.xml"

$my_dir/start-confluence.sh $1