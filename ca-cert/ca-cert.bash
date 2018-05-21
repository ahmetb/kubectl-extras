#!/usr/bin/env bash
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
