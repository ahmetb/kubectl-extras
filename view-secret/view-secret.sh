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

# Requires:
# - jq
# - kubectl
# - base64
set -eo pipefail

test -z "${1}" && echo >&2 "error: secret name required" && exit 1
secret="${1}"
key="${2}"


function _kube_list_secs() {
    IFS=';' read -ra items <<< "$(kubectl get secret "${secret}" -o=json | jq -r '.data | keys[]' | sort -t: | tr '\n' ';')"
    local count=1
    lines=$(for i in "${items[@]}"; do
        IFS=":" read -ra TOKS <<< "${i}"
        printf "  %s) %s\t%s\n" $count "${TOKS[0]}"
        ((count=count+1))
    done | column -t)
    count=$(echo "$lines" | wc -l)
    echo "$lines" >&2
    local sel=0
    while [[ $sel -lt 1 || $sel -gt $count ]]; do
        read -r -p "Select a key: " sel >&2
    done
    echo "${items[(sel-1)]}"
}


if [[ -z "${key}" ]]; then
    IFS=":" read -ra keys <<< "$(_kube_list_secs)"

    mapfile -t keys < <(kubectl get secret "${secret}" \
        -o=json | jq -r '.data | keys[]')

    if [[ "${#keys[@]}" -gt 1 ]]; then
        echo >&2 "Multiple sub keys found. Specify another argument, one of:"
        for k in "${keys[@]}"; do
            echo >&2 "-> ${k}"
        done
        exit 1
    elif [[ "${#keys[@]}" -eq 1 ]]; then
        key="${keys[0]}"
        echo >&2 "Choosing key: ${key}"
    else
        echo >&2 "Unexpected situation, no data in secret"
        exit 1
    fi
fi

escaped_key="${key//./\\.}"

kubectl get secret "${secret}" \
    -o=jsonpath=\{.data."${escaped_key}"\} | base64 --decode
