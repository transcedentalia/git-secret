#!/usr/bin/env bash


function reveal {

  OPTIND=1
  local homedir=""
  local passphrase=""
  local override=""

  while getopts "hfd:p:" opt; do
    case "$opt" in
      h) _show_manual_for "reveal";;

      p) passphrase=$OPTARG;;

      d) homedir=$OPTARG;;

      f) override="--yes";;
    esac
  done

  shift $((OPTIND-1))
  [ "$1" = "--" ] && shift

   _user_required

  local counter=0
  while read line; do
    local encrypted_filename=$(_get_encrypted_filename "$line")

    local base="$SECRETS_GPG_COMMAND --use-agent -q --decrypt"
    if [[ ! -z "$homedir" ]]; then
      base="$base --homedir=$homedir"
    fi

    if [[ ! -z "$passphrase" ]]; then
      echo "$passphrase" | $base --batch --yes --no-tty --passphrase-fd 0 -o "$line" "$encrypted_filename"
    else
      if [[ -z "$override" ]]; then
        $base -o "$line" "$encrypted_filename"
      else
        $base -o "$line" "$override" "$encrypted_filename"
      fi
    fi

    counter=$((counter+1))
  done < "$SECRETS_DIR_PATHS_MAPPING"

  echo "done. all $counter files are revealed."
}
