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

# Cleans up parents without owner references on all namespaces.
# Requires:
# - kubectl
# - jq
# - grep

set -eo pipefail

pods="$(set -e; kubectl get pod --all-namespaces -o json | \
    jq -r '.items[] | select(.metadata.ownerReferences | length==0) | .metadata.namespace+"/"+.metadata.name')"

readarray -t arr <<< "${pods}"

for p in "${arr[@]}"; do
    ns="${p%%/*}"
    po="${p##*/}"

    if [[ ! "$po" =~ ^kube-proxy ]]; then
    (
        set -x
        kubectl delete pod "${po}" --namespace="${ns}"
    )
    fi
done
