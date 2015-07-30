#!/usr/bin/env bash
[[ $_ == $0 ]] && echo "this is not an executable" && exit 1
dir="$( dirname "${BASH_SOURCE[0]}" )"

. $dir/upvars.sh

function thinder_check_storage_environment {
	if [[ ! -f $THINDER_BTRFS_IMAGE ]]; then
		critical "The Thinder storage environment container could not be found"
		notice "expected storage environment container location: '$THINDER_BTRFS_IMAGE'"
		info "use 'thinder storage create' to create a storage environment container"
		return 1
	fi
}