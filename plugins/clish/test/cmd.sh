#!/bin/sh

check_help "$@"

echo "Plugin $PLUGIN_NAME"
echo
echo "Environment:"
echo "  CLI_ROOT_PATH = $CLI_ROOT_PATH"
echo "  CLI_MAIN_COMMAND = $CLI_MAIN_COMMAND"
echo "  CLI_VERSION = $CLI_VERSION"
echo "  CLI_PLUGINS_PATH = $CLI_PLUGINS_PATH"
echo
echo "Parameter : $@"
echo
echo "Edit the initialization file at $CLI_PLUGINS_PATH/$PLUGIN_NAME/init.sh"
echo "Edit the command file at $CLI_PLUGINS_PATH/$PLUGIN_NAME/cmd.sh"
echo "Edit the help file at $CLI_PLUGINS_PATH/$PLUGIN_NAME/help.txt"
