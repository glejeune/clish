#!/bin/sh

PLUGIN_DESCRIPTION="Create a new $CLI_MAIN_COMMAND CLI project"
PLUGIN_AUTHORS="Greg"
PLUGIN_VERSION="0.0.1"
PLUGIN_NOT_REMOVABLE=1

check_files_and_dirs() {
  for _D in "$@" ; do
    if [ ! -d "$_D" ] && [ ! -f "$_D" ] ; then
      echo "$_D not found"
      exit 1
    fi
  done
}

ok() {
  _MSG="$1"
  read -p " > $_MSG [n|y] (n): " -r _resp
  case "$_resp" in
    "y" | "Y" | "yes" | "YES" | "Yes")
      echo "1"
      ;;
    *)
      echo "0"
      ;;
  esac
}

create_or_update_file() {
  _SRC="$1"
  _DST="$2"
  _DELETE="$3"

  if [ -f "$_DST" ] ; then
    _H_SRC=$(cat "$_SRC" | openssl sha512 | sed -e 's/^.*= *//')
    _H_DST=$(cat "$_DST" | openssl sha512 | sed -e 's/^.*= *//')

    if [ "$_H_SRC" = "$_H_DST" ] ; then
      echo " * Skip $_DST (no change)"
    else
      if [ "z$YES" = "z" ] ; then
        _OK=$(ok "Update $_DST ?")
      else
        _OK=1
      fi
      if [ "z$_OK" = "z1" ] ; then
        echo " * Update $_DST"
        cp -f "$_SRC" "$_DST"
      else
        echo " * Update $_DST (skipped)"
      fi
    fi
  else
    echo " * Create $_DST"
    _DST_PATH=$(dirname "$_DST")
    [ ! -d "$_DST_PATH" ] && mkdir -p "$_DST_PATH"
    cp "$_SRC" "$_DST"
  fi
  [ "$_DELETE" = "true" ] && rm "$_SRC"
}

create_main_cli() {
  cat "$CLI_ROOT_PATH/$CLI_MAIN_COMMAND" | \
    sed \
    -e "s/CLI_REPO=.*$/CLI_REPO=\"$(escape "$NEW_CLI_REPO")\"/" \
    -e "s/CLI_VERSION=.*$/CLI_VERSION=\"$(escape "$NEW_CLI_VERSION")\"/" > "$1"
}

create_or_update_plugins() {
  eval IMPORT_$IMPORT_INDEX="init"
  IMPORT_INDEX=$((IMPORT_INDEX + 1))
  eval IMPORT_$IMPORT_INDEX="plugins"
  IMPORT_INDEX=$((IMPORT_INDEX + 1))
  eval IMPORT_$IMPORT_INDEX="help"
  for I in $(seq 0 $IMPORT_INDEX) ; do
    P=$(eval echo \$IMPORT_"$I")
    if [ ! -d "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME/$P" ] || [ "z$FORCE" = "z1" ]  ; then
      echo " * Import plugin $P"
      cp -r "$CLI_ROOT_PATH/plugins/$CLI_MAIN_COMMAND/$P" "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME/"
    else
      echo " * Update plugin $P"
      for _PF in $(find "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME/$P" -type f) ; do
        create_or_update_file "$_PF" "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME/$P/$(basename "$_PF")"
      done
    fi
  done
}

create() {
  if [ -d "$NEW_CLI_PATH" ] && [ "z$UPDATE" = "z" ] ; then
    echo "Directory $NEW_CLI_PATH already exists! Use --update" >&2
    exit 1
  fi
  
  echo "Create new CLI $NEW_CLI_NAME at $NEW_CLI_PATH"
  
  echo " * Create root directory $NEW_CLI_PATH"
  mkdir -p "$NEW_CLI_PATH"
  echo " * Create $NEW_CLI_PATH/$NEW_CLI_NAME"
  create_main_cli "$NEW_CLI_PATH/$NEW_CLI_NAME"
  chmod +x "$NEW_CLI_PATH/$NEW_CLI_NAME"

  echo " * Create plugin directory $NEW_CLI_PATH/plugins/$NEW_CLI_NAME"
  mkdir -p "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME"
  
  create_or_update_plugins
}

update() {
  check_files_and_dirs \
    "$NEW_CLI_PATH" \
    "$NEW_CLI_PATH/$NEW_CLI_NAME" \
    "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME"

  echo "Update CLI $NEW_CLI_NAME in $NEW_CLI_PATH"

  CLI_MAIN_TMP=$(mktemp)
  create_main_cli "$CLI_MAIN_TMP"
  create_or_update_file "$CLI_MAIN_TMP"  "$NEW_CLI_PATH/$NEW_CLI_NAME" "true"

  create_or_update_plugins
}
