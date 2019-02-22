#!/bin/bash

export AUTOSWITCH_VERSION='0.1'

RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[35m"
BOLD="\e[1m"
NORMAL="\e[0m"
DEFAULT_PYTHON=/usr/bin/python3

if ! type "virtualenv" > /dev/null; then
    export DISABLE_AUTOSWITCH_VENV="1"
    printf "${BOLD}${RED}"
    printf "autoswitch-virtualenv requires virtualenv to be installed!\n\n"
    printf "${NORMAL}"
    printf "If this is already installed but you are still seeing this message, \n"
    printf "then make sure the ${BOLD}virtualenv${NORMAL} command is in your PATH.\n"
    printf "\n"
fi

# virtualenvwrapper setup
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export WORKON_HOME=~/.virtualenvs
mkdir -p $WORKON_HOME
source /usr/local/bin/virtualenvwrapper.sh



# search recursively for a file in the current directory and all parent directories
function upsearch()
{
  # adapted from http://stackoverflow.com/a/7614803/358804
  find `( CP=${PWD}; while [ -n "$CP" ] ; do echo $CP; CP=${CP%/*}; done; echo /)` -mindepth 1 -maxdepth 1 -type f -name $1
}

function auto_virtualenv()
{
  # check if directory changed
  if [ "$PWD" != "$MYOLDPWD" ]; then
    MYOLDPWD="$PWD"
    REQUIREMENTS_PATH=$(upsearch requirements.txt)
    MAYBEVENV_PATH=$(upsearch .venv)
    if [[ -f "$REQUIREMENTS_PATH" || -f "$PWD/setup.py" ]]; then
      # in a Python project
      printf "Python project detected.\n"

      # http://stackoverflow.com/a/34109556/358804
      CURRENT_PROJECT=$(awk -F/ '{ print $(NF-1) }' <<< "$REQUIREMENTS_PATH")
      OLD_PROJECT=${VIRTUAL_ENV##*/}


      # check if the project has .venv 
      if [ ! -f "$MAYBEVENV_PATH" ]; then
        printf "Run ${PURPLE}mkvenv${NORMAL} to setup autoswitching\n"
      # check if the project has changed, since `workon` is slow
      elif [ "$CURRENT_PROJECT" != "$OLD_PROJECT" ]; then
        workon "$CURRENT_PROJECT"
      fi
    elif [ -n "$VIRTUAL_ENV" ]; then
      # left a Python project
      deactivate
    fi
  fi
}

function mkvenv() {
  REQUIREMENTS_PATH=$(upsearch requirements.txt)
  CURRENT_PROJECT=$(awk -F/ '{ print $(NF-1) }' <<< "$REQUIREMENTS_PATH")

  if [[ -f ".venv" ]]; then
    printf ".venv file already exists. If this is a mistake use the rmvenv command\n"
  else
    local venv_name="$(basename $PWD)"
    printf "Creating ${PURPLE}%s${NONE} virtualenv\n" "$venv_name"

    # Copy parameters variable so that we can mutate it
    params=("${@[@]}")

    if [[ -n "$DEFAULT_PYTHON" && ${params[(I)--python*]} -eq 0 ]]; then
      params+="--python=$DEFAULT_PYTHON"
    fi

    mkvirtualenv $params "$CURRENT_PROJECT"
    printf "$venv_name\n" > ".venv"
    chmod 600 .venv

    workon "$CURRENT_PROJECT"
    install_requirements
  fi
}

function rmvenv() {
  REQUIREMENTS_PATH=$(upsearch requirements.txt)
  CURRENT_PROJECT=$(awk -F/ '{ print $(NF-1) }' <<< "$REQUIREMENTS_PATH")
  if [[ -f ".venv" ]]; then
    deactivate
    printf "Removing ${PURPLE}venv in $CURRENT_PROJECT ${NORMAL}...\n"
    rm -rf "$WORKON_HOME/$CURRENT_PROJECT"
    rm -rf ".venv"
  else
    printf "No .venv file in the current directory!\n"
  fi
}


function install_requirements() {
    REQUIREMENTS_PATH=$(upsearch requirements.txt)
    if [[ -f "$REQUIREMENTS_PATH" ]]; then
        printf "Install default requirements? (${PURPLE}$REQUIREMENTS_PATH${NORMAL}) [y/N]: "
        read ans

        if [[ "$ans" = "y" || "$ans" == "Y" ]]; then
            pip install -r "$REQUIREMENTS_PATH"
        fi
    fi

    if [[ -f "$PWD/setup.py" ]]; then
        printf "Found a ${PURPLE}setup.py${NORMAL} file. Install dependencies? [y/N]: "
        read ans

        if [[ "$ans" = "y" || "$ans" = "Y" ]]; then
            pip install .
        fi
    fi

    setopt nullglob
    for requirements in *requirements.txt
    do
        printf "Found a ${PURPLE}%s${NORMAL} file. Install? [y/N]: " "$requirements"
        read ans

        if [[ "$ans" = "y" || "$ans" = "Y" ]]; then
            pip install -r "$requirements"
        fi
    done
}

# bash hook
PROMPT_COMMAND='auto_virtualenv'

# Mirrored support for zsh. See: https://superuser.com/questions/735660/whats-the-zsh-equivalent-of-bashs-prompt-command/735969#735969
function precmd()
{
  eval "$PROMPT_COMMAND"
}
