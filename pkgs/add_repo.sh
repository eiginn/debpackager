#!/bin/bash

repo="$1"

mkdir -p "$(basename "$repo")"

gh repo view "$repo" --json 'name,owner,description,url,licenseInfo,latestRelease' | gomplate -d repo=stdin:///in.json -f ./_template/PKGBUILD.ttmpl | tee "$(basename "$repo")/PKGBUILD"
