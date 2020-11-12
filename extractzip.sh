#!/bin/bash

shopt -s nullglob

if [ "${CONFIG_DIR}" = '' ] ; then
    echo Incomplete configuration: Missing CONFIG_DIR environment variable
    exit
fi

function getFindPattern() {
  local patterns
  local i=0

  if [[ -f "$PATTERN_FILE" ]] ; then
    patterns=$(cat "$PATTERN_FILE")
  else
    patterns=$(cat << __EOF__
\*.zip
\*.ear
\*.sar
\*.war
\*.jar
\*.ejb
__EOF__
)
  fi

  echo "Looking for ZIP files matching ${patterns//$'\n'/ } in $INPUT_DIR"

  for arg in $patterns; do
    findArgs[$i]="-o -name $arg"
    ((++i))
  done

  findArgs[0]=$(echo "${findArgs[0]}" | cut -c3-100)
}

function extract() {
	if [[ -f "$1" ]] ; then
		echo "Unzipping $1..."

		mv "$1" jens
		mkdir -p "$1"
		mv jens "$1/"

		(cd "$1" || exit ; unzip jens ; rm jens)
	fi
}

function list() {
    local currentDir=$PWD

    echo "Searching for matching files in $currentDir"

    # Workaround: Create temporary script
    echo find . "${findArgs[@]}" -type f > "$TMP_DIR"/script1.sh

    for file in $(sh "$TMP_DIR"/script1.sh) ; do
      	echo "Extracting $file in $currentDir..."
      	extract "${file}"
      	echo "Extracting $file in $currentDir DONE"

      	cd "${file}" || exit
      	list
      	cd "$currentDir" || exit
    done

    rm -f "$TMP_DIR"/script1.sh
}

# shellcheck disable=SC2164
(cd "$INPUT_DIR" ; tar cf - .) | (cd "$WORK_DIR" ; tar xf -)

getFindPattern

# shellcheck disable=SC2164
cd "$WORK_DIR"
list

read -p "Press any key to continue ..."
