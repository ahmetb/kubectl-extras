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
ns="${3}"

if [[ -z "${key}" ]]; then
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
    -o=jsonpath=\{.data."${escaped_key}"\} --namespace "${ns}" | base64 --decode
