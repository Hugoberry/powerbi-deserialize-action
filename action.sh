#!/bin/bash
# -- config -- #
TMP_PREFIX='~' # prefix unzipped directory--should NOT conflict with 
               # anything in your repo
IFS='
'
# -- end config -- #

echo
echo "=== Start of PBIT processing ===="

# unzip the pbit file 
unpack_pbit () {
    if [ -e "$1" ]; then
        if [ -e "${TMP_PREFIX}$1" ]; then rm -rf "${TMP_PREFIX}$1"; fi
        7z x "$1" -o"./${TMP_PREFIX}$1"
    else
        # abort the commit if this isn't an pbit file somehow
        echo ""$1" is not an pbit file. this is a bug."
        exit 3
    fi
}

#rename files that are of json format
add_extensions () {
    if [ -e "$1/Connections" ]; then
        mv "$1/Connections" "$1/Connections.json"
    fi
    if [ -e "$1/DiagramLayout" ]; then
        iconv -f UTF-16LE -t UTF-8 "$1/DiagramLayout" > "$1/DiagramLayout.json"
        rm -rf  "$1/DiagramLayout"
    fi
    if [ -e "$1/Metadata" ]; then
        iconv -f UTF-16LE -t UTF-8 "$1/Metadata" > "$1/Metadata.json"
        rm -rf  "$1/Metadata"
    fi
    if [ -e "$1/Settings" ]; then
        iconv -f UTF-16LE -t UTF-8 "$1/Settings" > "$1/Settings.json"
        rm -rf  "$1/Settings"
    fi
    if [ -e "$1/Report/Layout" ]; then
        iconv -f UTF-16LE -t UTF-8 "$1/Report/Layout" > "$1/Report/Layout.json"
        rm -rf  "$1/Report/Layout"
    fi
	if [ -e "$1/DataModelSchema" ]; then
        iconv -f UTF-16LE -t UTF-8 "$1/DataModelSchema" > "$1/DataModelSchema.json"
        rm -rf "$1/DataModelSchema"
    fi
}

#unzip the data mashup file
unpack_data_mashup () {
    if [ -e "$1/DataMashup" ]; then
        if [ -e "$1/${TMP_PREFIX}DataMashup" ]; then rm -rf "$1/${TMP_PREFIX}DataMashup"; fi
        7z x "$1/DataMashup" -o"./$1/${TMP_PREFIX}DataMashup"
    else
        echo ""$1" couldn't find a DataMashup file"
        exit 3
    fi
}

# remove the binary files from the pbit file
remove_binaries () {
    if [ -e "$1/SecurityBindings" ]; then
        rm -rf  "$1/SecurityBindings"
    fi

    if [ -e "$1/DataMashup" ]; then
        rm -rf  "$1/DataMashup"
    fi
}

# reformat the json file to many lines
reformat_jsons () {
    for i in $(find "$1" -name "*.json" -type f); do
        jq . "$i" > "$i.tmp" && mv "$i.tmp" "$i"
    done
}

# unpack all the zipfiles (if the pbit has been staged)
pbitFiles=$(gh pr diff $PR_NUMBER --name-only )
echo "$pbitFiles"
for i in  $pbitFiles; do 
    if "${i##*.}" == "pbit"; then
        dir=$(dirname "$i")
        file=$(basename "$i")
        cd "$dir"
        unpack_pbit "$file"
        # TODO it might fail if file is in use, create a check
        add_extensions "${TMP_PREFIX}$file"
        unpack_data_mashup "${TMP_PREFIX}$file"
        remove_binaries "${TMP_PREFIX}$file"
        reformat_jsons "${TMP_PREFIX}$file"
        cd -
    fi
done

echo "=== End of PBIT processing ==="
echo
