#!/usr/bin/env bash
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
