launch_starship() {
	local _latest_starship
	local _starship_time

	if [[ -x $HOME/src/starship/target/release/starship ]]; then
		_latest_starship=$HOME/src/starship/target/release/starship
		_starship_time=$( stat -f %m "$_latest_starship" )
	fi

	if [[ -x $HOME/src/starship/target/debug/starship ]]; then
		if [[ -n $_latest_starship ]]; then
			if [[ $( stat -f %m $HOME/src/starship/target/debug/starship ) -gt $_starship_time ]]; then
				_load_debug "debug starship is the newer binary"
				_latest_starship=$HOME/src/starship/target/debug/starship
			else
				_load_debug "release starship is the newer binary"
			fi
		else
			_latest_starship=$HOME/src/starship/target/debug/starship
		fi
	fi

	if [[ -z $_latest_starship ]]; then
		if has starship; then
			_load_debug "using installed starship"
			eval "$( starship init zsh )"
		fi
	else
		_load_debug "using starship at $_latest_starship"
		eval "$( $_latest_starship init zsh)"
	fi
}
