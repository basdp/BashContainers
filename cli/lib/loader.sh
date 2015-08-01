LOADER_ROOT="$( dirname "${BASH_SOURCE[0]}" )/../"

function include {
	local varized=included_$(echo "$1" | sed 's/[^a-zA-Z0-9]/_/g')
	if [[ ! "${!varized:-}" == "1" ]]; then
		. "${LOADER_ROOT}$1"
	fi 
	declare ${varized}=1
}