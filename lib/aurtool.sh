# shellcheck shell=sh
# shellcheck disable=SC2001
# shellcheck disable=SC2181

get_upstream_version() {
  :
}


get_gitaur_version() {
  host="$1"

  if [ -z "$host" ]; then
    echoe "Host parameter can not be empty when fetching host version"
    return 1
  fi

}


get_hostaur_version() {
  :
}




#
## MAIN FUNCTIONS


get_package_version() {
  pkg_name="$1"



  if [ -z "$package_name" ]; then
    echoe "--pkgname parameter can not be empty when fetching version"
    return 1
  fi


}

add_ghtoken() {
  token="$1"

  if [ -z "$token" ]; then
    echoe "Upstream repo url parameter can not be empty."
    return 1
  fi

  if has_github_token; then
    echow "Github Token is already set!"
    if ! askyesno "Do you want to overwrite Github Token entry in database file?" "n"; then
      echoi "No changes made to database file."
      return 1
    fi
  fi

  set_github_token "$token"

  echos "Succesfully added Github Token to database file"
}


add_package() {
  url="$1"


  if [ -z "$url" ]; then
    echoe "Repo --url parameter can not be empty."
    return 1
  fi

  if ! has_github_token; then
    echoe "You have to set Github Token to prevent being limited by API"
    return 1
  fi

  # Strip extension if necessary
  url="${url%%.git}"

  # Parse owner and repo from URL
  owner_repo=$(echo "$url" | awk -F'github.com/' '{print $NF}')
  owner=$(echo "$owner_repo" | awk -F'/' '{print $1}')
  repo=$(echo "$owner_repo" | awk -F'/' '{print $2}')

  # Fetch necessary data from Github API
  upstream_url=$(get_gh_repo "$owner" "$repo" | jq -r '.html_url')
  latest_rel=$(get_gh_repo_release "$owner" "$repo" | jq -r '.[0]')
  pre_rel=$(echo "$latest_rel" | jq -r '.prerelease')
  last_update=$(echo "$latest_rel" | jq -r '.updated_at')
  tag_name=$(echo "$latest_rel" | jq -r '.tag_name')

  # Add to database file
  set_package_upstream_value "$repo" "url" "$upstream_url"
  set_package_upstream_value "$repo" "last_update" "$last_update"
  set_package_upstream_value "$repo" "latest_version" "$tag_name"
  set_package_upstream_value "$repo" "pre_release" "$pre_rel"

  set_package_aurrepo_value "$repo" "url" "$DA_BASE_URL/$repo"

  echos "Succesfully added package to database file"
}

get_package_info() {
  :
}

