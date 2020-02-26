#!/bin/sh

PLUGIN_VERSION="0.0.1"
PLUGIN_DESCRIPTION="Get/Set $CLI_MAIN_COMMAND config"
PLUGIN_AUTHORS="Greg"

__CONFIG_KEYS_LIST=""

list_config_from() {
  CONFIG_FILE=$1
  CONFIG_KEY=$2
  if [ -e "$CONFIG_FILE" ]; then
    while read LINE; do
      LINE=`echo $LINE | sed -e 's/#.*$//'`
      if [ ! "x$LINE" = "x" ]; then
        FOUND_CONFIG_KEY=`echo $LINE | sed -e 's/=.*$//'`
        if [ "x$CONFIG_KEY" = "x" ] || [ "$CONFIG_KEY" = "$FOUND_CONFIG_KEY" ] ; then
          CONFIG_KEY_PRESENT=`echo $__CONFIG_KEYS_LIST | grep ":$FOUND_CONFIG_KEY"`
          if [ "x$CONFIG_KEY_PRESENT" = "x" ] ; then
            __CONFIG_KEYS_LIST=$__CONFIG_KEYS_LIST:$FOUND_CONFIG_KEY
            echo $LINE
          fi
        fi
      fi
    done < "$CONFIG_FILE"
  fi
}

list_config() {
  __CONFIG_KEYS_LIST=""
  list_config_from "$HOME/.config/$CLI_MAIN_COMMAND/config"
  list_config_from "$CLI_ROOT_PATH/default_config.sh"
}

get_config() {
  KEY=$1
  __CONFIG_KEYS_LIST=""
  list_config_from "$HOME/.config/$CLI_MAIN_COMMAND/config" "$KEY"
  list_config_from "$CLI_ROOT_PATH/default_config.sh" "$KEY"
}

set_config() {
  KEY=$1
  VALUE=$2
  CONFIG_KEY_PRESENT=`cat "$CLI_ROOT_PATH/default_config.sh" | grep "^$KEY"`
  if [ "x$CONFIG_KEY_PRESENT" = "x" ] ; then
    echo "Invalid config key $KEY"
    exit 1
  fi

  [ -f "$HOME/.config/$CLI_MAIN_COMMAND/config" ] || touch "$HOME/.config/$CLI_MAIN_COMMAND/config"
  CONFIG_KEY_PRESENT=`cat "$HOME/.config/$CLI_MAIN_COMMAND/config" | grep "^$KEY"`
  if [ "x$CONFIG_KEY_PRESENT" = "x" ] ; then
    echo "$KEY=\"$VALUE\"" >> "$HOME/.config/$CLI_MAIN_COMMAND/config"
  else
    sed -i -e "s#$KEY=.*#$KEY=\"$VALUE\"#" "$HOME/.config/$CLI_MAIN_COMMAND/config"
  fi
}
