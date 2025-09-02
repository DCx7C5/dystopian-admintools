# shellcheck shell=sh
# shellcheck disable=SC2001
# shellcheck disable=SC2034
# shellcheck disable=SC2181


askyesno() {
    default="$2"
    case "$default" in
        y|Y|yes|Yes|YES)
            question=$(printf "%s [Y/n]: " "$1")
            default_return=0
            ;;
        n|N|no|No|NO)
            question=$(printf "%s [y/N]: " "$1")
            default_return=1
            ;;
        *)
            question=$(printf "%s [y/N]: " "$1")
            default_return=1
            ;;
    esac
    while true; do
        printf "\033[1m\033[1;33m>\033[0m\033[1m %s\033[0m" "$question"
        read -r yesno
        case "$yesno" in
            y|Y|j|J|yes|Yes|YES) return 0;;
            n|N|no|NO|No) return 1;;
            "") return $default_return;;
            * ) ;;
        esac
    done
}


echoi() {
    if [ "$QUIET" -ne 1 ]; then
        if [ "$DEBUG" -eq 1 ]; then istr="   INFO:"; else istr=""; fi
        printf "\033[1m\033[1;36m>%s\033[0m\033[1;37m\033[1m %s\033[0m\n" "$istr" "$1"
    fi
}


echov() {
    if [ "$VERBOSE" -eq 1 ]; then
        if [ "$DEBUG" -eq 1 ]; then istr="   INFO:"; else istr=""; fi
        printf "\033[1m\033[1;36m>%s\033[0m\033[1;37m\033[1m %s\033[0m\n" "$istr" "$1"
    fi
}


echod() {
    if [ "$DEBUG" -eq 1 ]; then
        printf "\033[1m\033[1;37m>  DEBUG:\033[0m %s\n" "$1"
    fi
}


echow() {
    if [ "$QUIET" -ne 1 ]; then
      printf "\033[1m\033[1;33m> WARNING:\033[0m\033[1;37m\033[1m %s\033[0m\n" "$1" >&2
    fi
}


echowv() {
    if [ "$VERBOSE" -eq 1 ]; then
        echow "$1"
    fi
}


echoe() {
    printf "\033[1m\033[1;31m>  ERROR:\033[0m\033[1;37m\033[1m %s\033[0m\n" "$1" >&2
}


echos() {
    if [ "$QUIET" -ne 1 ]; then
        printf "\033[1m\033[1;32m>>>\033[0m\033[1;37m\033[1m %s\033[0m\n" "$1"
    fi
}


echosv() {
  if [ "$VERBOSE" -eq 1 ]; then
      if [ "$DEBUG" -eq 1 ]; then istr="   INFO:"; else istr=""; fi
      printf "\033[1m\033[1;32m>%s\033[0m\033[1;37m\033[1m %s\033[0m\n" "$istr" "$1"
  fi
}


is_ip() {
    ip="$1"
    if echo "$ip" | grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' >/dev/null 2>&1; then
        return 0
    elif echo "$ip" | grep -E '^([0-9a-fA-F]{1,4}:){0,7}[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){0,7}$|^::1$' >/dev/null 2>&1; then
        return 0
    fi
    return 1
}


shorthelp() {
  echo ""
  help | sed -n "/^  $1/,/^$/p"
}


set_permissions_and_owner() {
    perm="$2"
    if [ "$DYSTOPIAN_USER" = "root" ] && [ "$perm" -eq 440 ]; then
        perm=400
    fi
    if ! chmod "$perm" "$1" 2>/dev/null; then
        echoe "Failed to set permissions $perm on $1"
        return 1
    fi
    if ! chown "root:${DYSTOPIAN_USER}" "$1" 2>/dev/null; then
        echoe "Failed to set owner root:${DYSTOPIAN_USER} on $1"
        return 1
    fi
    if [ "$1" != "$DC_DB" ]; then
        echov "Successfully set perm ($perm) and owner 'root:$DYSTOPIAN_USER' on $1"
    else
        echod "Successfully set perm ($perm) and owner 'root:$DYSTOPIAN_USER' on $1"
    fi
    return 0
}

absolutepath() {
    if which realpath >/dev/null 2>&1; then
        realpath -- "$1"
    else
        dir="$(dirpath "$1")"
        basename="${1##*/}"
        echo "$dir/$basename"
    fi
    return 0
}


absolutepathidx() {
    dir="$(dirpath "$1")"
    basename="${1##*/}"
    ext="${basename##*.}"
    base="${basename%*".$ext"}"

    if [ ! -f "$dir/$base.$2.$ext" ]; then
        echo "$dir/$base.$2.$ext"
        return 0
    fi

    c=1
    while [ -f "$dir/$base.$2.$c.$ext" ]; do
        c=$(("$c" + 1))
    done
    echo "$dir/$base.$2.$c.$ext"
}


dirpath() {
    path="$1"
    resolved_path=""

    case "$path" in
        /*)
            work_path="$path"
            ;;
        *)
            # The check ensures we don't add a trailing slash if pwd is just "/"
            current_dir=$(pwd)
            if [ "$current_dir" = "/" ]; then
                work_path="/$path"
            else
                work_path="$current_dir/$path"
            fi
            ;;
    esac

    set -f # Temporarily disable globbing to handle components like '*'.
    IFS='/' # Set the Internal Field Separator to '/' to split the path.
    for component in $work_path; do
        case "$component" in
            "" | ".")
                continue
                ;;
            ..)
                resolved_path=$(echo "$resolved_path" | sed 's|/[^/]*$||')
                ;;
            *)
                resolved_path="$resolved_path/$component"
                ;;
        esac
    done
    unset IFS
    set +f

    if [ -z "$resolved_path" ]; then
        echo "/"
    else
        echo "$resolved_path"
    fi
    return 0
}


filename() {
    if which basename >/dev/null 2>&1; then
        basename -- "$1"
        return 0
    fi
    echo "$1" | awk -F'/' '{print $NF}'
}


get_index_from_filename() {
    basename="${1##*/}"
    ext="${basename##*.}"
    base="${basename%*".$ext"}"
    if echo "$base" | grep -qE '\.'; then
        echo "$base" | awk -F. '{print $NF}'
        return 0
    fi
    return 1
}


_cleanup() {
    echod "Cleaning up generated files..."
    for file in $DYSTOPIAN_CLEANUP_FILES; do
        rm -rf -- "$file"
    done
    echod "done."
}




get_gh_repo() {
  owner="$1"
  repo="$2"
  curl -s -L \
       -H "Authorization: Bearer $(get_github_token)" \
       -H 'Accept: application/json' \
       "$GH_API_BASE/$owner/$repo" || {
         echoe "Error fetching repo from Github Api"
         return 1
       }
  return 0
}


get_gh_repo_release() {
  owner="$1"
  repo="$2"
  curl -s -L \
       -H "Authorization: Bearer $(get_github_token)" \
       -H "Accept: application/json" \
       "$GH_API_BASE/$owner/$repo/releases" || {
         echoe "Error fetching release from Github Api"
         return 1
       }
  return 0
}


backup_targz() {
  path="${1:+$(absolutepath "$1")}"
  [ -d "$path" ] || return 0
  dirname="$(echo "$path" | awk -F'/' '{print $NF}')"
  parent="${path%"$dirname"}"
  [ -d "$parent" ] || return 0
  # choose a timestamped name (YYYYmmdd_HHMMSS) and avoid collisions by adding a counter
  ts="$(date +%Y%m%d_%H%M%S)"
  outfile="${dirname}.bkp.${ts}.tar.gz"
  cnt=0
  while [ -e "$outfile" ]; do
    cnt=$((cnt + 1))
    outfile="${dirname}.bkp.${ts}.${cnt}.tar.gz"
  done
  # create tarball from parent so archive contains base/...
  if tar -C "$parent" -czf "$outfile" -- "$dirname" 2>/dev/null; then
    printf 'Created backup: %s\n' "$outfile"
  else
    printf 'Failed to create backup: %s\n' "$outfile" >&2
    rm -f -- "$outfile" || true
    return 1
  fi
  return 0
}

# Replace the existing preparse implementation with this one
preparse() {
    DC_POS_ARGS=""
    mcmd="$1"
    shift
    while [ $# -gt 0 ]; do
        if [ "$1" = "--user" ] && echo "$mcmd" | grep -qE "hosts$|aurtool$"; then
            if [ $# -gt 1 ]; then
                DYSTOPIAN_USER="$2"
                shift 2
            else
                echoe "--user requires an argument"; exit 1
            fi
        fi
        case "$1" in
            --verbose|-v) VERBOSE=1; shift;;
            --quiet|-q) DEBUG=0; VERBOSE=0; QUIET=1; shift;;
            --debug) DEBUG=1; VERBOSE=1; shift;;
            *)
                if [ -z "$DC_POS_ARGS" ]; then
                    DC_POS_ARGS=$1
                else
                    DC_POS_ARGS=$DC_POS_ARGS"||$1"
                fi
                [ "$#" -gt 0 ] && shift
                ;;
        esac
    done
}
