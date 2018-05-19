#!/usr/bin/env bash
# Opens the Google Kubernetes Engine console on the browser.
# Requires:
# - gcloud
# - kubectl
# - jq
# Supported platforms:
# - macOS
set -euo pipefail

gcloud_project="$(gcloud config get-value core/project 2>/dev/null)"
if [[ -z "${gcloud_project}" ]]; then
    echo >&2 "project ID is not configured on gcloud"
fi

master_url="$(kubectl config view --minify -o=jsonpath='{.clusters[*].cluster.server}')"
if [[ -z "${master_url}" ]]; then
    echo >&2 "master ip not found"
    exit 1
fi
master_ip="${master_url#https\:\/\/}"

v="$(gcloud container clusters list --filter=endpoint="${master_ip}" \
    --format=json | jq -r '.[].zone+"/"+.[].name')"

if [[ -z "$v" ]]; then
    echo >&2 "Current cluster not in project '${gcloud_project}'?"
    exit 1
fi

echo "Launching UI for ${v##*/} in ${gcloud_project}..."
url="https://console.cloud.google.com/kubernetes/clusters/details/"${v}"?project=${gcloud_project}"
open "${url}"
