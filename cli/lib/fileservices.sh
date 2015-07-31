#!/usr/bin/env bash
[[ $_ == $0 ]] && echo "this is not an executable" && exit 1
dir="$( dirname "${BASH_SOURCE[0]}" )"

. $dir/upvars.sh

function print_progress {
	# $1 = percentage
	# $2 = description
	width=50
	filled=$(( $1 * $width / 100 ))
	printf '\033[K['
	printf '#%.0s' $( seq 1 $filled )
	[[ $filled -lt $width ]] && printf ' %.0s' $( seq $filled $width )
	printf '] %d%% ' $1
	echo -en $2
}

function copytree {
	cp -a $1 $2 &
	cp_pid=$!
	sourcesize=$(du -s $1 2> /dev/null | awk '{print $1}')
	while kill -s 0 $cp_pid &> /dev/null; do # while cp is running
		START=$(date +%s.%N)
		copyprogress="$( du -s $2  2> /dev/null | awk '{print $1}' | sed 's/[^0-9.]*//g' || echo 0 )" || true
		END=$(date +%s.%N)
		SECS=$(LC_ALL="en_US.UTF-8" awk -v start="${START}" -v end="${END}" 'BEGIN { printf "%.2f", (end-start)*5; exit(0) }')
		percentage=$(( ($copyprogress * 100) / $sourcesize ))
		print_progress $percentage 'Copying...\r'
		sleep $SECS
	done
	print_progress 100 'Copied.\n'
	return 0
}

function extract_targz {
	tar xzSf $1 -C $2 &
	tar_pid=$!
	sourcesize=$(gzip -l $1 | tail -n 1 | awk '{print $2}')
	output=$(tar --list -f $1 | head -n 1) || true
	while kill -s 0 $tar_pid &> /dev/null; do # while tar is running
		START=$(date +%s.%N)
		progress="$( du -sb $2/$output  2> /dev/null | awk '{print $1}' | sed 's/[^0-9.]*//g' || echo 0)" || true
		END=$(date +%s.%N)
		SECS=$(LC_ALL="en_US.UTF-8" awk -v start="${START}" -v end="${END}" 'BEGIN { printf "%.2f", (end-start)*5; exit(0) }')
		percentage=$(( ($progress * 100) / $sourcesize ))
		print_progress $percentage 'Extracting...\r'
		sleep $SECS
	done
	print_progress 100 'Extracted.\n'
	
	return 0
}