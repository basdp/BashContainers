#!/usr/bin/env bash
[[ $_ == $0 ]] && echo "this is not an executable" && exit 1
dir="$( dirname "${BASH_SOURCE[0]}" )"

. $dir/upvars.sh

function print_progress {
	# $1 = percentage
	# $2 = description
	width=50
	filled=$(( $1 * $width / 100 ))
	printf '['
	printf '#%.0s' $( seq 1 $filled )
	[[ $filled -lt $width ]] && printf ' %.0s' $( seq $filled $width )
	printf '] %d%% ' $1
	echo -en $2
}

function copytree {
	cp -a $1 $2 &
	cp_pid=$!
	sourcesize=$(du -s $1 | awk '{print $1}')
	while kill -s 0 $cp_pid &> /dev/null; do # while cp is running
		START=$(date +%s.%N)
		copyprogress="$(export | du -s $2 | awk '{print $1}' | sed 's/[^0-9.]*//g' )"
		END=$(date +%s.%N)
		SECS=$(LC_ALL="en_US.UTF-8" awk -v start="${START}" -v end="${END}" 'BEGIN { printf "%.2f", (end-start)*5; exit(0) }')
		percentage=$(( ($copyprogress * 100) / $sourcesize ))
		print_progress $percentage '\r'
		sleep $SECS
	done
	print_progress 100 '\n'
	return 0
}
