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

# Tails log lines from multiple pods (selected by label selector).
# Requires:
# - kubectl

set -eo pipefail

test -z "${1}" && echo "label selector required." && echo "Usage e.g. kubectl mtail app=my-service -n my-ns my-container" 1>&2 && exit 1

selector="$1"
namespace="$2 $3"
container="$4"

pods=$(kubectl get pods -l="app=identity-service" -n argonauts -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')

for po in $pods; do
    (
        set -ex
        kubectl $namespace logs --follow "${po}" --tail=10 $container \
    ) | sed "s/^/$(tput setaf 3)[${po}] $(tput sgr0)/" &
    # TODO(ahmetb) add more colors and pick one for each pod
done

trap "exit" INT TERM ERR
trap "kill 0" EXIT
wait
