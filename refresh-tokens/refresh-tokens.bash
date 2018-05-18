#!/usr/bin/env bash
# Make a request on each context to refresh the access tokens.

mapfile -t ctx < <(kubectl config get-contexts -o=name)

for c in "${ctx[@]}"; do
    (
        timeout --preserve-status 15 \
            kubectl version --context="${c}" 1>/dev/null
        ec=$?
        if [ $ec -eq 0 ]; then
            echo >&2 "Refreshed token for \"${c}\""
        else
            echo >&2 "Failed to refresh token for \"${c}\""
        fi
    )&
done

trap "exit" INT TERM ERR
trap "kill 0" EXIT
wait
echo "Done."
