# shellcheck shell=sh
# shellcheck disable=SC2001

# Set secure umask for all temporary file operations in this library
umask 077


set_github_token() {
  temp_file=$(mktemp -- "${DA_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg val "$1" '.GITHUB_TOKEN = $val' -- "$DA_DB" > "$temp_file" || {
    echoe "Failed setting value for GITHUB_TOKEN"
    return 1
  }

  mv -- "$temp_file" "$DA_DB" || {
    echoe "Failed moving temporary database file"
    rm -f -- "$temp_file"
    return 1
  }
  return 0
}


get_github_token() {
  jq -r '.GITHUB_TOKEN // empty' -- "$DA_DB" || {
    echoe "Failed getting GITHUB_TOKEN"
    return 1
  }
  return 0
}


has_github_token() {
  jq -e '.GITHUB_TOKEN? // "" | (type == "string") and (length > 0)' -- "$DA_DB" >/dev/null 2>&1
}


add_package() {
  temp_file=$(mktemp -- "${DA_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg idx "$1" \
        '.packages[$idx] = {}' -- "$DA_DB" > "$temp_file" || {
          echoe "Failed adding new package to database"
          return 1
        }

  mv -- "$temp_file" "$DA_DB" || {
    echoe "Failed moving temporary database file"
    rm -f -- "$temp_file"
    return 1
  }

  return 0
}


set_package_upstream_value() {
  temp_file=$(mktemp -- "${DA_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg idx "$1" \
        --arg key "$2" \
        --arg val "$3" \
        '.packages[$idx].upstream[$key] = $val' -- "$DA_DB" > "$temp_file" || {
          echoe "Failed setting package upstream key & value"
          return 1
        }

  mv -- "$temp_file" "$DA_DB" || {
    echoe "Failed moving temporary database file"
    rm -f -- "$temp_file"
    return 1
  }

  return 0
}


set_package_gitaur_value() {
  temp_file=$(mktemp -- "${DA_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg idx "$1" \
        --arg key "$2" \
        --arg val "$3" \
        '.packages[$idx].aur_repo[$key] = $val' -- "$DA_DB" > "$temp_file" || {
          echoe "Failed setting package gitaur key & value"
          return 1
        }

  mv -- "$temp_file" "$DA_DB" || {
    echoe "Failed moving temporary database file"
    rm -f -- "$temp_file"
    return 1
  }

  return 0
}


set_package_hostaur_value() {
  temp_file=$(mktemp -- "${DA_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg idx "$1" \
        --arg key "$2" \
        --arg val "$3" \
        '.packages[$idx].hostaur[$key] = $val' -- "$DA_DB" > "$temp_file" || {
          echoe "Failed setting package hostaur key & value"
          return 1
        }

  mv -- "$temp_file" "$DA_DB" || {
    echoe "Failed moving temporary database file"
    rm -f -- "$temp_file"
    return 1
  }

  return 0
}


get_package_upstream_value() {
  jq -r --arg idx "$1" \
        --arg key "$2" \
        '.packages[$idx].upstream[$key] // empty' -- "$DA_DB" || {
          echoe "Failed getting package upstream value"
          return 1
        }
  return 0
}


get_package_gitaur_value() {
  jq -r --arg idx "$1" \
        --arg key "$2" \
        '.packages[$idx].gitaur[$key] // empty' -- "$DA_DB" || {
          echoe "Failed getting package gitaur value"
          return 1
        }
  return 0
}

get_package_hostaur_value() {
  jq -r --arg idx "$1" \
        --arg key "$2" \
        '.packages[$idx].hostaur[$key] // empty' -- "$DA_DB" || {
          echoe "Failed getting package gitaur value"
          return 1
        }
  return 0
}

