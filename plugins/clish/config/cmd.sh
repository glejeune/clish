#!/bin/sh

case "$1" in
  list)
    echo "$CLI_MAIN_COMMAND config:"
    echo
    list_config
    ;;
  get)
    shift
    CONFIG_KEY=$1
    get_config "$CONFIG_KEY"
    ;;
  set)
    shift
    CONFIG_KEY=$1
    CONFIG_VALUE=$2
    set_config "$CONFIG_KEY" "$CONFIG_VALUE"
    ;;
  *)
    if [ -z "$1" ] ; then
      __help --msg "missing sub command" --plugin "$PLUGIN_NAME" --exit 1
    else
      __help --msg "invalid sub command $1" --plugin "$PLUGIN_NAME" --exit 1
    fi
esac
