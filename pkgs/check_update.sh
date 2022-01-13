#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shut up undefined varibles warning in shellcheck:
pkgver=
pkgname=
ghrepo=
_check_rc_prerelease=

die() {
  echo "$@" >&2
  exit 1
}

for pkgbuild in $(find "$SCRIPT_DIR" -maxdepth 2 -name PKGBUILD); do
  (
    pushd "$(dirname "$pkgbuild")" &> /dev/null || exit 1
    . "$pkgbuild"
    if [[ $_check_rc_prerelease == true ]]; then
      rc_prerelease_filter=''
    else
      rc_prerelease_filter='| select(.tag_name | test(".*(rc|beta).*"; "i") | not)'
    fi
    latestver="$(gh api "repos/${ghrepo}/releases" | jq -r '[.[] '"${rc_prerelease_filter}"' | .tag_name] | .[0]')"
    if ! [[ $latestver ]]; then
      set -x
      gh api "repos/${ghrepo}/releases" | jq -r '[.[] '"${rc_prerelease_filter}"' | .tag_name] | .[0]'
      set +x
    fi
    if [[ $pkgver != "${latestver#v}" ]]; then
      echo "$pkgname is out of date. Newest: ${latestver#v} Have: $pkgver"
      if ! [[ $(git status --porcelain -- "$pkgbuild") ]]; then
        sed -i -e "s/pkgver=${pkgver}/pkgver=${latestver#v}/" "$pkgbuild"
      fi
    fi
    popd &> /dev/null || exit 1
  )
done
