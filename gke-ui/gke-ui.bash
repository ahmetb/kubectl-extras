#!/usr/bin/env bash
#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
