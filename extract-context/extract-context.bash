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

# Prints a kubeconfig YAML file for the specified context by minifying the file
# and redacting the access token.
set -eo pipefail


test -z "$1" && echo "error: context name required" 1>&2 && exit 1
ctx="$1"

cur_ctx="$(kubectl config current-context)"
if [[ -z "${cur_ctx}" ]]; then
    echo >&2 "error: current context is not set"
    exit 1
fi

# switch back
kubectl config use-context "${ctx}" || (
    echo >&2 "error: failed to switch to context"
    exit 1
)

kubectl config view --minify --flatten | \
    grep -v 'access-token:' | \
    grep -v 'expiry:'

# switch back
kubectl config use-context "${cur_ctx}" 2>&1 1>/dev/null
