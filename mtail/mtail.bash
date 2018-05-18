#!/usr/bin/env bash
set -eo pipefail

test -z "${1}" && echo "label selector required." 1>&2 && exit 1

selector="$1"
mapfile -t arr < <(kubectl get pods -l="${selector}" \
    -n="${KUBECTL_PLUGINS_CURRENT_NAMESPACE}" \
    -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')

for po in "${arr[@]}"; do
    (
        set -ex
        kubectl logs --follow "${po}" --tail=10 \
            -n="${KUBECTL_PLUGINS_CURRENT_NAMESPACE}"
    ) | sed "s/^/$(tput setaf 3)[${po}] $(tput sgr0)/" &
    # TODO(ahmetb) add more colors and pick one for each pod
done

trap "exit" INT TERM ERR
trap "kill 0" EXIT
wait
