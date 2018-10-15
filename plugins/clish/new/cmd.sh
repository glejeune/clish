#!/bin/sh

IMPORT_INDEX=0
while [ "$1" ] ; do
  case "$1" in
    "--force" | "-f" )
      FORCE=1 ;
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

echo "Create new cli $NEW_CLI_NAME at $NEW_CLI_PATH"

if [ -d "$NEW_CLI_PATH" ] && [ "z$FORCE" = "z" ] ; then
  echo "Directory $NEW_CLI_PATH already exists! Use --force" >&2
  exit 1
fi

echo " * Create root directory $NEW_CLI_PATH"
mkdir -p "$NEW_CLI_PATH"
echo " * Create $NEW_CLI_PATH/$NEW_CLI_NAME"
cat "$CLI_ROOT_PATH/$CLI_MAIN_COMMAND" | \
  sed \
  -e "s/CLI_REPO=.*$/CLI_REPO=\"$(escape "$NEW_CLI_REPO")\"/" \
  -e "s/CLI_VERSION=.*$/CLI_VERSION=\"$(escape "$NEW_CLI_VERSION")\"/" > "$NEW_CLI_PATH/$NEW_CLI_NAME"
chmod +x "$NEW_CLI_PATH/$NEW_CLI_NAME"
echo " * Create plugin directory $NEW_CLI_PATH/plugins/$NEW_CLI_NAME"
mkdir -p "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME"

echo " * Initialize plugins list"
touch "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME/list.txt"

eval IMPORT_$IMPORT_INDEX="init"
IMPORT_INDEX=$((IMPORT_INDEX + 1))
eval IMPORT_$IMPORT_INDEX="plugins"
IMPORT_INDEX=$((IMPORT_INDEX + 1))
eval IMPORT_$IMPORT_INDEX="help"
for I in $(seq 0 $IMPORT_INDEX) ; do
  P=$(eval echo \$IMPORT_"$I")
  if [ ! -d "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME/$P" ] || [ "z$FORCE" = "z1" ]  ; then
    echo " * import plugin $P"
    cp -r "$CLI_ROOT_PATH/plugins/$CLI_MAIN_COMMAND/$P" "$NEW_CLI_PATH/plugins/$NEW_CLI_NAME/"
  fi
done
