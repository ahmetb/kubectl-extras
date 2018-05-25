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


# Prints the CA cert of the current cluster in PEM format.
#
# Requires:
# - base64
set -eo pipefail


cur_ctx="$(kubectl config current-context)"
if [[ -z "${cur_ctx}" ]]; then
    echo >&2 "error: current context is not set"
    exit 1
fi

kubectl config view --minify --flatten \
    -o=go-template='{{(index (index .clusters 0).cluster "certificate-authority-data")}}' |\
    base64 --decode
