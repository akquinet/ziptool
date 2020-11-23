#!/bin/bash

shopt -s nullglob

if [ "${CONFIG_DIR}" = '' ]; then
  echo Incomplete configuration: Missing CONFIG_DIR environment variable
  exit
fi

function getFindPattern() {
  local patterns
  local i=0

  if [[ ! -f "$PATTERN_FILE" ]]; then
    cat <<__EOF__ >"$PATTERN_FILE"
\*.zip
\*.ear
\*.sar
\*.war
\*.jar
\*.ejb
__EOF__
  fi

  while read -r pattern; do
    echo Pattern $i = "$pattern"
    patterns[$i]=$pattern
    findArgs[$i]="-o -name $pattern"

    ((++i))
  done <"$PATTERN_FILE"

  local size="${#findArgs[@]}"

  # shellcheck disable=SC2145
  echo "Looking for files matching ${patterns[@]//$'\n'/ } ($size patterns) in $INPUT_DIR"

  if [ "$size" == 0 ]; then
    echo Invalid number of patterns
    exit
  fi

  findArgs[0]=$(echo "${findArgs[0]}" | cut -c4-100)

  # Workaround: Create temporary script
  script="$TMP_DIR/script.sh"
  command="find . "${findArgs[@]}" -type f"

  echo "$command" >"$script"
}

function extract() {
  if [[ -f "$1" ]]; then
    echo "Unzipping $1..."

    mv "$1" jens
    mkdir -p "$1"
    mv jens "$1/"

    (
      cd "$1" || exit
      unzip jens
      rm jens
    )
  fi
}

function listAndExtract() {
  local currentDir=$PWD

  echo "Searching for matching files in $currentDir"
  echo "Running $command ......"

  for file in $(sh "$script"); do
    echo "Extracting $file in $currentDir..."
    extract "${file}"
    echo "Extracting $file in $currentDir DONE"

    cd "${file}" || exit
    listAndExtract
    cd "$currentDir" || exit
  done
}

function wait() {
  read -rp "Press any key to continue ..."
}

mkdir -p "$INPUT_DIR" "$WORK_DIR" "$TMP_DIR" "$SCRIPT_DIR" "$OUTPUT_DIR"

ln -f "$INPUT_DIR"/* "$WORK_DIR"

getFindPattern

# shellcheck disable=SC2164
cd "$WORK_DIR"
listAndExtract

echo Executing provided scripts ...
# shellcheck disable=SC1090
bash "$SCRIPT_DIR"/*.sh

