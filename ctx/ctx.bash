#!/bin/bash
set -eu

command -v kubectx >/dev/null 2>&1 || {
        echo >&2 "kubectx not installed"; exit 1; }

kubectx "$@"
