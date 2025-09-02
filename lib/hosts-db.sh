# shellcheck shell=sh
# shellcheck disable=SC2001

# Set secure umask for all temporary file operations in this library
umask 077


set_default_host() {
  temp_file=$(mktemp -- "${DH_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg val "$1" '.defaultHost = $val' -- "$DH_DB" > "$temp_file" || {
    rm -f -- "$temp_file"
    return 1
  }

  mv -- "$temp_file" "$DH_DB" || {
    echoe "Failed moving $DH_DB"
    rm -f -- "$temp_file"
    return 1
  }

  rm -f -- "$temp_file" || {
    echoe "Removing $temp_file failed"
    rm -f -- "$temp_file"
    return 1
  }
  return 0
}


get_default_host() {
  jq -r '.defaultHost // empty' -- "$DH_DB" || {
    echoe "Failed getting default host"
    return 1
  }
  return 0
}



add_host() {
  temp_file=$(mktemp -- "${DH_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg idx "$1" '.hosts[$idx] = {}' -- "$DH_DB" > "$temp_file" || {
    echoe "Failed creating host entry in database"
    return 1
  }
  return 0
}


set_host_value() {
  temp_file=$(mktemp -- "${DH_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  if [ "$#" -eq 3 ]; then
    jq -e --arg idx "$1" \
          --arg key "$2" \
          --arg val "$3" \
          '.hosts[$idx][$key] = $val' -- "$DH_DB" > "$temp_file" || {
            echoe "Failed setting $2 = $3 at $1"
            rm -f -- "$temp_file"
            return 1
          }
  elif [ "$#" -eq 1 ]; then
    jq -e --arg idx "$1" \
          '.hosts[$idx] = {}' -- "$DH_DB" > "$temp_file" || {
            echoe "Failed creating new host index: $1"
            rm -f -- "$temp_file"
            return 1
          }
  else
    return 1
  fi

  mv -- "$temp_file" "$DH_DB" || {
    echoe "Failed moving $DH_DB"
    rm -f -- "$temp_file"
    return 1
  }
  return 0
}


has_host_value() {
  if [ "$#" -eq 2 ]; then
    jq -e --arg hst "$1" \
          --arg val "$2" \
          '.hosts[$hst][$val]? // "" |
           (type == "string") and (length > 0)' -- "$DH_DB" >/dev/null 2>&1
  else
    jq -e --arg hst "$1" \
          '.hosts[$hst]? // "" |
          (type == "string") and (length > 0)' -- "$DH_DB" >/dev/null 2>&1
  fi
}


get_host_value() {
  jq -e --arg idx "$1" \
        --arg key "$2" \
        '.hosts[$idx][$key]' -- "$DH_DB" || {
          echoe "Failed getting value from host entry"
          return 1
        }
  return 0
}
