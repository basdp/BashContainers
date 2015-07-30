#!/usr/bin/env bash
[[ $_ == $0 ]] && echo "this is not an executable" && exit 1
dir="$( dirname "${BASH_SOURCE[0]}" )"

. $dir/upvars.sh

function get_os {
	if grep "Ubuntu" /etc/lsb-release &> /dev/null; then
		local "$1" && upvar $1 "Ubuntu";
		return 0
	fi
	if grep "CentOS" /etc/system-release &> /dev/null; then
		local "$1" && upvar $1 "CentOS";
		return 0
	fi
	if grep "Fedora" /etc/system-release &> /dev/null; then
		local "$1" && upvar $1 "Fedora";
		return 0
	fi
	if grep "Red Hat" /etc/system-release &> /dev/null; then
		local "$1" && upvar $1 "Red Hat";
		return 0
	fi
	warning "couldn't find the current operating system type" 
	local "$1" && upvar $1 $(uname -s);
	return 0
}