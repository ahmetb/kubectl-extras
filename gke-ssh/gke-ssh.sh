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

# SSHes into the node of the that the pod is running on.
# Requires:
# - gcloud
# - kubectl
# - ssh
# Supported platforms:
# - macOS
# - Linux
set -eo pipefail

test -z "${1}" && echo "error: specify Pod name" 1>&2 && exit 1
set -u

pod_name="${1}"

# TODO(ahmetb) support $KUBE_NAMESPACE (kubectl plugin -n NS [...])
node_name="$(kubectl get pods -o=jsonpath='{.spec.nodeName}' "${pod_name}")"
echo >&2 "pod ${1} is running on node \"${node_name}\""

vms="$(gcloud compute instances list --format='csv(name,zone)')"
entry="$(echo "${vms}" | grep "${node_name}," || true)"
zone="$(cut -d "," -f 2 <<< "$entry")"
if [[ -z "${zone}" ]]; then
    echo >&2 "could not determine zone for node (is the node on another GCP project?)"
    exit 1
fi
echo >&2 "node \"${node_name}\" is in zone \"${zone}\"" 

set -x
gcloud compute ssh --zone="${zone}" "${node_name}"
