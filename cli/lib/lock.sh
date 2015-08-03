function lock() {
	while [[ -f "$THINDER_ROOT/$1.lock" ]]; do
		sleep "0.$(( RANDOM % 100 ))"
	done
	
	touch "$THINDER_ROOT/$1.lock"
}

function unlock() {
	rm -f "$THINDER_ROOT/$1.lock"
}