#!/usr/bin/env bash

re='^https?://([[:alnum:].-]+)([:/?#]|$)'

if [[ ! $QUTE_URL =~ $re ]]; then
    echo "Regex doesn't match this url" >&2
    exit 1
fi
host=${BASH_REMATCH[1]}

list="$QUTE_CONFIG_DIR/darkreader-excludes.txt"
out="$QUTE_CONFIG_DIR/darkreader-excludes.js"

touch "$list"
echo "$host" | LC_ALL=C sort - "$list" --unique -o "$list"

{
    echo 'window.__darkReaderExcluded = new Set(['
    sed 's/.*/  "&",/' "$list"
    echo ']);'
} > "$out"

require_cache_file="file://$out"
rm "$QUTE_DATA_DIR/greasemonkey/requires/${require_cache_file//\//_}"

echo "greasemonkey-reload" > "$QUTE_FIFO"
echo "reload --force" > "$QUTE_FIFO"
