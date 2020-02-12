#!/bin/sh

IMPORT_INDEX=0
NEW_CLI_BRANCH="master"

while [ "$1" ] ; do
  case "$1" in
    "--yes" | "-y" )
      YES=1 ;
      shift ;;
    "--update" | "-u" )
      UPDATE=1 ;
      shift ;;
    "--path" | "-p" )
      shift ;
      NEW_CLI_PATH=$1
      [ -n "$NEW_CLI_PATH" ] || __help --plugin "$PLUGIN_NAME" --exit 1 --msg "Invalid path"
      shift ;;
    "--repo" | "-r" )
      shift ;
      NEW_CLI_REPO=$1
      shift ;;
    "--branch" | "-b" )
      shift ;
      NEW_CLI_BRANCH=$1
      shift ;;
    "--version" | "-v" )
      shift ;
      NEW_CLI_VERSION=$1
      shift ;;
    "--import" | "-i" )
      shift ;
      IMPORT=1
      while [ "$IMPORT" = "1" ] ; do
        case "$1" in
          -*)
            IMPORT=0
            ;;
          *)
            if [ -n "$1" ] ; then
              if [ ! -d "$CLI_PLUGINS_PATH/$1" ] ; then
                echo "Plugin $1 is not installed" >&2
                exit 1
              fi
              eval IMPORT_$IMPORT_INDEX=\$1
              IMPORT_INDEX=$((IMPORT_INDEX + 1))
              shift
            else
              IMPORT=0
            fi
            ;;
        esac
      done
      ;;
    "--")
      shift ;;
    -*)
      __help --plugin "$PLUGIN_NAME" --exit 1 --msg "$1: Invalid option"
      shift ;;
    *)
      NEW_CLI_NAME="$1"
      [ "z$NEW_CLI_PATH" = "z" ] && NEW_CLI_PATH="$PWD/$NEW_CLI_NAME"
      shift;;
  esac
done

if [ "z$NEW_CLI_NAME" = "z" ] ; then
  __help --plugin "$PLUGIN_NAME" --exit 1 --msg "CLI name missing!"
fi

[ ! -d "$NEW_CLI_PATH" ] && [ "z$UPDATE" = "z" ] && UPDATE=0

if [ "$UPDATE" = "1" ] ; then
  update
else
  create
fi
