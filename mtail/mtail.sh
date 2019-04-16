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


# Argument parsing generated online by https://argbash.io/generate
die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

begins_with_short_option()
{
	local first_option all_short_options
	all_short_options='ch'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_container=

print_help ()
{
	printf '%s\n' "The general script's help msg"
	printf 'Usage: %s [-c|--container <arg>] [-h|--help] <label-selector>\n' "$0"
	printf '\t%s\n' "<label-selector>: Label selector to use, comma separated, i.e. app=prometheus,tier=system"
	printf '\t%s\n' "-c,--container: specify container (no default)"
	printf '\t%s\n' "-h,--help: Prints help"
}

parse_commandline ()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-c|--container)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_container="$2"
				shift
				;;
			--container=*)
				_arg_container="${_key##--container=}"
				;;
			-c*)
				_arg_container="${_key##-c}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_positionals+=("$1")
				;;
		esac
		shift
	done
}

handle_passed_args_count ()
{
	_required_args_string="'label-selector'"
	test ${#_positionals[@]} -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${#_positionals[@]}." 1
	test ${#_positionals[@]} -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
}

assign_positional_args ()
{
	_positional_names=('_arg_label_selector' )

	for (( ii = 0; ii < ${#_positionals[@]}; ii++))
	do
		eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args

label_selector=${_positionals[0]}

while IFS= read -r line; do
    arr+=("$line")
done < <(kubectl get pods -l="${label_selector}" -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')

for po in "${arr[@]}"; do
    (
        set -ex
        kubectl logs --follow "${po}" "${_arg_container}" --tail=10 \
    ) | sed "s/^/$(tput setaf 3)[${po}] $(tput sgr0)/" &
    # TODO(ahmetb) add more colors and pick one for each pod
done

trap "exit" INT TERM ERR
trap "kill 0" EXIT
wait
