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

function is_writable {
	if touch "$1/.__tmp_writecheck" &> /dev/null; then
		rm -f "$1/.__tmp_writecheck"
		return 0
	else
		return 1
	fi
}

function thinder_check_storage {
	thinder_check_storage_environment || return 1
	if ! mount | grep -q "$THINDER_ROOT"; then
		critical "No storage container has been connected to the Thinder environment"
		notice "expected storage environment mountpoint: '$THINDER_ROOT'"
		info "use 'thinder storage connect' to connect a storage container"
		return 1
	fi
	if ! is_writable "$THINDER_ROOT"; then
		critical "The storage container is not writable"
		notice "The storage container at '$THINDER_ROOT' is not writable by the current user ($(whoami))"
		return 1
	fi
	return 0
}