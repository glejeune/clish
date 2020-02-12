git_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
echo ${ref#refs/heads/}
}

FORCE=0
[ "$1" = "--force" ] && FORCE=1

cd "$CLI_ROOT_PATH"
echo "Update $CLI_MAIN_COMMAND ($(git_branch))"
if [ "$FORCE" = "1" ] ; then
  git reset --hard
  git fetch --all
  git checkout $CLI_STABLE_BRANCH
  git reset --hard origin/$CLI_STABLE_BRANCH
else
  git pull origin $(git_branch) 2>/dev/null
  if [ "$?" != "0" ] ; then
    echo "Update failed try to use --force"
  else
    echo "Done!"
  fi
fi
cd - 2>&1 1>/dev/null
