if [[ -z $_zsh_done_env ]]; then
	_zsh_done_env=1
	# Ensure that a non-login, non-interactive shell has a defined environment.
	if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
	  source "${ZDOTDIR:-$HOME}/.zprofile"
	fi

	export PATH="/usr/local/bin:$PATH"

	# Thing to add to PATH, if they exist
	DIRS=(
		/opt/homebrew/bin
		/opt/homebrew/sbin
		~/.toolbox/bin
		/usr/local/opt/ruby/bin
		/usr/X11R6/bin
		~/bin
		~/Library/Python/2.7/bin
		~/Library/Python/3.7/bin
		~/Library/Python/3.6/bin
		~/.local/bin
		~/.cargo/bin
		~/go/bin
		~/.pyenv/bin
		~/src/sessionmanager-bundle/bin
		/usr/local/opt/ruby/bin
		/usr/local/lib/ruby/gems/2.6.0/bin
		~/.local/gem/bin
		~/.yarn/bin
		~/.config/yarn/global/node_modules/.bin
		"~/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
		~/esp/xtensa-esp32-elf/bin
		~/.rvm/bin
		)

	export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
	for d in $DIRS; do
		if [ -d $d ]; then
			export PATH=$d:$PATH
		fi
	done

	if [[ -x "${HOMEBREW_PREFIX:-/usr/local}/bin/pyenv" ]]; then
		_zsh_load_info="$_zsh_load_info\ninitialised pyenv"
		eval "$(${HOMEBREW_PREFIX:-/usr/local}/bin/pyenv init --path)"
		if [[ -x "${HOMEBREW_PREFIX:-/usr/local}/bin/pyenv-virtualenv" ]]; then
			eval "$(${HOMEBREW_PREFIX:-/usr/local}/bin/pyenv virtualenv-init -)"
		fi
	fi

	path_bits=(${(s.:.)PATH})
	unique_path_bits=(${(u)path_bits[@]})
	unique_path=${(j.:.)unique_path_bits}
	export PATH=$unique_path

	path_bits=(${(s.:.)PYTHONPATH})
	unique_path_bits=(${(u)path_bits[@]})
	unique_path=${(j.:.)unique_path_bits}
	export PYTHONPATH=$unique_path

	if [[ -z $MANPATH ]]; then
		export MANPATH=$( man -w 2>/dev/null )
	fi

	#export GEM_PATH=$HOME/.local/gem
fi

if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
  source "${VIRTUAL_ENV}/bin/activate"
fi

export JAVA_TOOLS_OPTIONS="-Dlog4j2.formatMsgNoLookups=true"

alias reenv="unset _zsh_done_env; exec zsh"
