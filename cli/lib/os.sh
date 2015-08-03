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
	if grep "Raspbian" /etc/os-release &> /dev/null; then
		local "$1" && upvar $1 "Raspbian";
		return 0
	fi
	warning "couldn't find the current operating system type" 
	local "$1" && upvar $1 $(uname -s);
	return 0
}

function killtree {
	local _pid=$1
	local _sig=${2:-KILL}
	kill -stop ${_pid} # needed to stop quickly forking parent from producing children between child killing and parent killing
	# if ps doesn't support --ppid, one can use pgrep -P {$_pid} instead 
	for _child in $(ps -o pid --no-headers --ppid ${_pid}); do
		killtree ${_child} ${_sig}
	done
	kill -${_sig} ${_pid}
}