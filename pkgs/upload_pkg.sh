#!/bin/bash

file="$1"
[[ -r "${file}" ]] || { echo "Can't read file: ${file}"; exit 1; }
pkgname="$(dpkg-deb -f "${file}" Package)"
pkgver="$(dpkg-deb -f "${file}" Version)"

check_existing() {
  gcloud artifacts versions list --repository=noble-amd64 --location=us-west1 --package="${pkgname}" --format=json 2> /dev/null | jq --arg pkgver "/${pkgver}$" -e '.[]|select(.name|test($pkgver))'
}

(
  echo "Uploading: ${file}..."
  if ! check_existing; then
    gcloud beta artifacts apt upload noble-amd64 --location=us-west1 --source="${file}"
  fi
) |& sed -e 's/projects\/.*\/locations/projects\/REMOVED\/locations/g'
