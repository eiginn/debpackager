#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
repo="$1"

mkdir -p "${SCRIPT_DIR}/$(basename "$repo")"

gh repo view "$repo" --json 'name,owner,description,url,licenseInfo,latestRelease' | gomplate -d repo=stdin:///in.json -f "${SCRIPT_DIR}/_template/PKGBUILD.ttmpl" | tee "${SCRIPT_DIR}/$(basename "$repo")/PKGBUILD"
