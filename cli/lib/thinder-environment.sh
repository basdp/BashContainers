#!/usr/bin/env bash
[[ $_ == $0 ]] && echo "this is not an executable" && exit 1
dir="$( dirname "${BASH_SOURCE[0]}" )"

. $dir/upvars.sh
. $dir/config.sh

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

function thinder_get_image_id_from_name_and_version {
	## Gets the Image ID from the name and version
	
	thinder_check_storage || (critical "Storage is not sane" && exit 1)
	
	for image in "$THINDER_ROOT/images/"*; do
		if [[ -d "$image" ]] && [[ -f "$image/meta" ]]; then
			import_config_file "$image/meta"
			if [[ "$name" == "$1" ]] && [[ "$version" == "$2" ]]; then
				local ID=$(basename "$image")
				local "$3" && upvar $3 "$ID"
				return 0
			fi
		fi
	done
	
	local "$3" && upvar $3 ""
	return 1
}

function thinder_get_image_id_from_identifier {
	## Gets the Image ID from the image identifier (name:version)
	
	arr=(${1/\:/ })
	thinder_get_image_id_from_name_and_version "${arr[0]}" "${arr[1]}" "$2"
}

function thinder_get_image_id_from_string {
	if [[ -d "$THINDER_ROOT/images/$1" ]] && [[ -f "$THINDER_ROOT/images/$1/meta" ]]; then
		# id
		local "$2" && upvar $2 "$1"
		return 0
	fi
	thinder_get_image_id_from_identifier "$1" "$2"
}

function thinder_get_instance_id_from_name {
	## Gets the Instance ID from the name
		
	thinder_check_storage || (critical "Storage is not sane" && exit 1)
	
	for instance in "$THINDER_ROOT/instances/"*; do
		if [[ -d "$instance" ]] && [[ -f "$instance/meta" ]]; then
			import_config_file "$instance/meta"
			if [[ "$name" == "$1" ]]; then
				local ID=$(basename "$instance")
				local "$2" && upvar $2 "$ID"
				return 0
			fi
		fi
	done
	
	local "$2" && upvar $2 ""
	return 1
}