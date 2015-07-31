#!/usr/bin/env bash
[[ $_ == $0 ]] && echo "this is not an executable" && exit 1
dir="$( dirname "${BASH_SOURCE[0]}" )"

. $dir/upvars.sh

function import_config_file {
	errors=$(grep -vn '\(^[a-zA-Z0-9\.]\+\s*=\)\|\(^\s*\#\)\|\(^\s*$\)' $1) || true
	if [[ ! "$errors" = "" ]]; then
		critical "Syntax error in file $1:"
		echo $errors
		exit 1
	fi

	local tmp=$(mktemp)	
	cat $1 | sed 's/\#.*//' ` # remove comments on content lines` \
	       | grep '^[a-zA-Z0-9\.]\+\s*=' ` # only match key=value lines` \
	       | awk -F'=' '{gsub(/\./, "_", $1); gsub(/'"'"'/, "'"'"'\"'"'"'\"'"'"'", $2); print $1"="$2}' ` # replace the . with _ for keys and ' for \' for values` \
	       | perl -pe 's/^\s*([a-zA-Z0-9\_]+)\s*=\s*(.*?)\s*$/\1='"'"'\2'"'"'\n/g' ` # convert to bash variable definitions ` \
	       > $tmp
		  
	. $tmp
	rm -rf $tmp
}