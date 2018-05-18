#!/usr/bin/env bash
# Requires:
# - jq
# - kubectl
set -eo pipefail

test -z "${1}" && echo >&2 "error: secret name required" && exit 1
secret="${1}"
key="${2}"

if [[ -z "${key}" ]]; then
    mapfile -t keys < <(kubectl get secret "${secret}" \
        -n="${KUBECTL_PLUGINS_CURRENT_NAMESPACE}" \
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

escaped_key="${key/./\\.}"

kubectl get secret "${secret}" \
    -o=jsonpath=\{.data."${escaped_key}"\} | base64 ---decode
