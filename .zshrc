if [[ "$ZPROF" = true ]]; then
  zmodload zsh/zprof
fi

# get rid of fzf-tmux
export LANG=en_GB.UTF-8
setopt TRANSIENT_RPROMPT
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export HOMEBREW_NO_ANALYTICS=1
export SAM_CLI_TELEMETRY=0
export HOMEBREW_AUTO_UPDATE_SECS=86400

if hash gdate 2> /dev/null; then
	_has_gdate=1;
	_last_event=$(gdate +%s.%N)
	_zsh_load_info="hello world"
else
	_zsh_load_info="missing gdate, timestamps not available (brew install coreutils)"
fi

_load_debug() {
	if [[ -n $_has_gdate ]]; then
		now=$(printf "%.*f" 6 $( gdate +%s.%N))
		duration=$(printf '%.*f' 4 "$(($now - $_last_event))")
		_last_event=$now
		_zsh_load_info="$_zsh_load_info ($duration)\n$now $1"
	else
		now=""
		duration=""
		_zsh_load_info="$_zsh_load_info \n$1"
	fi
}

show-load-debug() {
	echo $_zsh_load_info | cat
}

_load_debug "initialising paths"
source ${ZDOTDIR:-$HOME/.zsh}/init-path.zsh

if [ -d /opt/homebrew/opt/zplug ]; then
	export ZPLUG_HOME=/opt/homebrew/opt/zplug
	source $ZPLUG_HOME/init.zsh
	_zplugin_available=1
	_load_debug "found zplug in /opt"
elif [ -d /usr/local/opt/zplug ]; then
	export ZPLUG_HOME=/usr/local/opt/zplug
	source $ZPLUG_HOME/init.zsh
	_zplugin_available=1
	_load_debug "found zplug in /usr"
else
	echo "Missing zplug"
	_load_debug "could not find zplug"
	_zplugin_available=0
fi

zstyle ':prezto:module:editor' key-bindings 'emacs'
zstyle ':prezto:module:editor' dot-expansion 'yes'

# Prepare prompt theme
#fpath=(${ZDOTDIR:-$HOME/.zsh}/local-plugins/prompt-sorin $fpath)
#autoload -Uz promptinit && promptinit

[ -d /usr/local/share/zsh/site-functions ] && fpath=(/usr/local/share/zsh/site-functions $fpath)

ZSH_LOCAL_PLUGINS="$HOME/.zsh/local-plugins"
for plugin in $ZSH_LOCAL_PLUGINS/*(/); do
	[ -f "$plugin/init.zsh" ] && _load_debug "sourcing local plugin $plugin" && source "$plugin/init.zsh"
done
unset ZSH_LOCAL_PLUGINS

if [[ $_zplugin_available == 1 ]]; then
	_load_debug "loading zplugins"
	zplug "mafredri/zsh-async"
	zplug "zsh-users/zsh-completions"
	zplug "zdharma/fast-syntax-highlighting"
	zplug "zsh-users/zsh-autosuggestions"

	if ! zplug check --verbose; then
		printf "Install? [y/N]: "
		if read -q; then
			echo; zplug install
		fi
	fi

	# Then, source plugins and add commands to $PATH
	zplug load
fi
unset _zplugin_available

unsetopt AUTO_CD

# Set up prompt
#prompt sorin
zstyle ':prezto:module:editor:info:keymap:primary' format '%B%F{31}%%%f%b'
zstyle ':prezto:module:editor:info:keymap:alternate' format '%B%F{1}$%f%b'

# Fix output of commands which don't print a newline at the end
setopt PROMPT_SP
export PROMPT_EOL_MARK="%F{red} %f"

# Things to source, if they exist
FILES=(
	~/.travis/travis.sh
	~/.iterm2_shell_integration.zsh
	~/.fzf.zsh
	~/.config/homebrew-token
	)

# Dirs to alias, if they exist
typeset -A ALIAS_DIRS
ALIAS_DIRS=(
	~/src src
	~/tmp tmp
	)

for d in "${(@k)ALIAS_DIRS}"; do
	if [ -d "$d" ]; then
		hash -d $ALIAS_DIRS[$d]=$d
		_load_debug "aliased dir $d"
	fi
done
unset d ALIAS_DIRS

export FZF_DEFAULT_OPTS='-e --height=15 --reverse'
export FZF_TMUX=0
if has rg; then
	export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" --glob "!*.pyc" 2> /dev/null'
	export FZF_CTRL_T_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" --glob "!*.pyc" 2> /dev/null'
	_load_debug "found rg and set up fzf"
	if [[ -r $HOME/.ripgreprc ]]; then
		_load_debug "set ripgrep config file"
		export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc
	fi
fi

[ -d ~/.config ] && export XDG_CONFIG_HOME=~/.config

has flake8 && alias flake8="flake8 --ignore=E501"
alias md5sum=md5

if has nvim; then
	alias vim=nvim
	alias vi=nvim
	export EDITOR=nvim
	export VISUAL=nvim
	export MANPAGER='nvim +Man!'
	export MANWIDTH=999
	alias ss="nvim --cmd 'let g:startify_disable_at_vimenter = 1' +SrcSearch"
else
	export EDITOR=vim
	export VISUAL=vim
fi

autoload colors && colors
REPORTTIME=10
TIMEFMT="$fg[green]%J$reset_color  $fg[blue]%U user $fg[yellow]%S system $fg[magenta]%P cpu $fg[red]%*E total"

for f in $FILES; do
	if [ -f $f ]; then
		_load_debug "sourced file $f"
		source $f
	fi
done
unset f FILES

# override from emacs-forword-word for the autosuggest feature
bindkey '^[f' forward-word

function fzf-cd-history() {
	dir=$( d | fzf --header="Recent directories" --inline-info --height=10 | awk '{print $1}' )
	if [[ ! -z $dir ]]; then
		cd ~$dir
	fi
}
zle -N fzf-cd-history
bindkey '^[d' fzf-cd-history

has docker && run-docker () {
	docker run -i -t --rm $1 /bin/bash
}

has docker && tidy-docker() {
	echo "--> Removing exited containers..."
	docker ps -a | awk ' /Exited/ {print $1}' | xargs -n1 docker rm
	echo
	echo "--> Removing untagged images..."
	docker images | awk ' /<none>/ { print $3 }' | xargs -n1 docker rmi
}

has fzf && autoload gita
has fzf && [[ ! -f $HOME/.fzf.zsh ]] && echo "Missing .fzf.zsh but fzf is installed. Run /usr/local/opt/fzf/install to finish setup!"
bindkey -e "^XG" git-commit-edit
if has exa; then
	alias lg='exa -l --git --color-scale --icons'
	alias ll='exa -l --color-scale --icons'
	alias lt='exa -l -T --git --color-scale --icons'
	exa-ls() {
		if [[ $1 == "-ltr" ]]; then
			shift
			exa -l -tmodified -r $@
		elif [[ $1 == "-lt" ]]; then
			shift
			exa -l -tmodified $@
		else
			exa $@
		fi
	}
	alias ls=exa-ls
	alias l="exa -1a"
	alias la="exa -a"
	_load_debug "found exa and configured aliases"
else
	lg-missing() { echo 'exa is not installed :(' }
	alias lg=lg-missing
fi

if has bat; then
	alias cat=bat
	export BAT_THEME=OneHalfDark
	export BAT_OPTS="-p"
fi

if [[ -x ~/src/cloud/post-image.sh ]]; then
	function post() {
		post_url=$( ~/src/cloud/post-image.sh "$1" )
		if [[ -n $post_url ]]; then
			echo "--> $post_url"
			post_url=$( echo -n $post_url | tr -d '\n' )
			export POST_LAST_URL=$post_url
			echo -n $post_url | pbc
		else
			echo "Failed."
		fi
	}
else
	function post() {
		echo 'cloud post-image.sh is not available or not executable'
	}
fi
alias post-recent-screenshot='post ~/Desktop/Screenshot\ *(om[1])'

nvm_home="$XDG_CONFIG_HOME/nvm"  # as used by the installer from their site
if [[ -f $nvm_home/nvm.sh ]]; then
	_load_debug "set up nvm loader"
	_zsh_load_nvm() {
		echo "Loading nvm..."
		manpath=$MANPATH
		export NVM_DIR="$nvm_home/.nvm"
		. "$nvm_home/nvm.sh"
		export MANPATH=$manpath
		unset manpath
		nvm $@
	}
	nvm(){
		_zsh_load_nvm $@
	}
fi

has direnv && eval "$(direnv hook zsh)"

# use path of $HOME as proxy for detecting OS X without running uname
if [[ $HOME =~ Users ]]; then
	alias tidy-finder="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user"
fi

# show available tmux sessions; uses async if available to avoid slowing down launch
_show_tmux_sessions() {
	if [[ -z $TMUX ]]; then
		if has tmux; then
			sessions=$( tmux ls 2> /dev/null | awk '! /attached/ { sub(":", "", $1); print $1; }' | xargs echo )
			if [[ ! -z $sessions ]]; then
				echo "==> Available tmux sessions: $sessions; run 't' to attach"
				zle -I
			fi
			unset sessions
		fi
	else
		if [[ ! -d $HOME/.tmux/plugins/tmux-sensible ]]; then
			echo '==> tmux plugins not installed?'
			zle reset-prompt
		fi
	fi
}

_tmux_sessions_callback() {
	if [[ -n $3 ]]; then
		print
		print $3
	fi
}

if typeset -f async_init > /dev/null; then
	async_start_worker tmux_sessions -n
	async_register_callback tmux_sessions _tmux_sessions_callback
	async_job tmux_sessions _show_tmux_sessions
else
	_show_tmux_sessions
fi

_zcompdump="$HOME/.zcompdump"
_load_debug "loading completions"
if [[ ! -f "$_zcompdump" ]]; then
	# Completion cache is older than 24h, regenerate
	compinit -d $_zcompdump
	_load_debug "ran compinit (missing)"
elif [[ -n $_zcompdump(#qN.mh+24) ]]; then
	# Completion cache is older than 24h, regenerate
	rm -f $_zcompdump
	compinit -d $_zcompdump
	_load_debug "ran compinit (too old)"
else
	# Completion cache is newish, load quickly
	compinit -C;
	_load_debug "used compinit cache"
fi
unset _zcompdump

if has isengardcli; then
	eval "$( command isengardcli shell-profile )" &!
	eval "$( command isengardcli shell-autocomplete )" &!
fi

# kick off a recompile of .zsh and the compdump file in the background, if needed
( autoload -U zrecompile && zrecompile -p ~/.zshrc -- ~/.zcompdump > /dev/null ) &!

# kick off rehash of pyenv shims in background
has pyenv && eval "$(pyenv init - --no-rehash)"
has pyenv && ( pyenv rehash ) &!

export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ARCH=$(arch)

launch_starship

_load_debug "fin"
unset -f _load_debug launch_starship

if [[ "$ZPROF" = true ]]; then
  zprof
fi
