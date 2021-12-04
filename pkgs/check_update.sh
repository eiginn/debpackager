#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

die() {
  echo "$@" >&2
  exit 1
}

for pkgbuild in $(find "$SCRIPT_DIR" -maxdepth 2 -name PKGBUILD); do
  (
    pushd "$(dirname "$pkgbuild")" &> /dev/null || exit 1
    . "$pkgbuild"
    latestver="$(gh release list --repo "$ghrepo" | grep Latest | awk '{print $1}')"
    if [[ $pkgver != "${latestver#v}" ]]; then
      echo "$pkgname is out of date. Newest: $latestver Have: $pkgver"
    fi
    popd &> /dev/null || exit 1
  )
done
