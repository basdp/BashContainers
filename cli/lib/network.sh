#!/usr/bin/env bash
[[ $_ == $0 ]] && echo "this is not an executable" && exit 1
dir="$( dirname "${BASH_SOURCE[0]}" )"
root=${0%/*}

. $dir/upvars.sh
. $dir/config.sh

function thinder_check_network_environment {
	if [[ "$(cat /proc/sys/net/ipv4/ip_forward)" == "0" ]]; then
		info "IP forwarding is disabled, enabling it for you"
		echo 1 > /proc/sys/net/ipv4/ip_forward
	fi
	fix_iptables=false
	[[ ! "$(iptables -t nat -L POSTROUTING -v | grep '\s\+thinder0\s\+'| grep '\s\+MASQUERADE\s\+' | wc -l)" == "1" ]] && 
		fix_iptables=true
	[[ ! "$(iptables -t nat -L POSTROUTING -v | grep '\s\+eth0\s\+'| grep '\s\+MASQUERADE\s\+' | wc -l)" == "1" ]] && 
		fix_iptables=true
		
	if $fix_iptables; then
		info "IP tables are not set up for routing to Thinder containers, setting it up for you"
		iptables --flush -t nat
		iptables -t nat -A POSTROUTING -o thinder0 -j MASQUERADE
		iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	fi
	
	if ! ip link show thinder0 > /dev/null 2>&1; then
		info "thinder0 link does not exist, creating it for you"
		ip link add thinder0 type bridge
		ip addr add 10.20.0.1/24 dev thinder0
		ip link set thinder0 up
	fi
}