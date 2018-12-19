# get rid of fzf-tmux
export LANG=en_GB.UTF-8
setopt TRANSIENT_RPROMPT
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export HOMEBREW_NO_ANALYTICS=1

_zsh_load_info=""

# Check for and load zplugin
if [ ! -f ~/.zplugin/bin/zplugin.zsh ]; then
	echo "Missing zplugin; expect errors!"
	echo "Fix: mkdir ~/.zplugin && git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin"
	_zplugin_available=0
else
	source ~/.zplugin/bin/zplugin.zsh
	_zplugin_available=1
fi

zstyle ':prezto:module:editor' key-bindings 'emacs'
zstyle ':prezto:module:editor' dot-expansion 'yes'

# Prepare prompt theme
fpath=(${ZDOTDIR:-$HOME/.zsh}/local-plugins/prompt-sorin $fpath)
autoload -Uz promptinit && promptinit

[ -d /usr/local/share/zsh/site-functions ] && fpath=(/usr/local/share/zsh/site-functions $fpath)

ZSH_LOCAL_PLUGINS="$HOME/.zsh/local-plugins"
for plugin in $ZSH_LOCAL_PLUGINS/*(/); do
	[ -f "$plugin/init.zsh" ] && source "$plugin/init.zsh"
done
unset ZSH_LOCAL_PLUGINS

if [[ $_zplugin_available == 1 ]]; then
	zplugin light "mafredri/zsh-async"
	zplugin light "jreese/zsh-titles"
	zplugin light "zsh-users/zsh-completions"
	zplugin light "zdharma/fast-syntax-highlighting"
	zplugin light "zsh-users/zsh-autosuggestions"
fi
unset _zplugin_available

unsetopt AUTO_CD

# Set up prompt
prompt sorin
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
	~/src/chef_repo/cookbooks chef
	~/src src
	)

for d in "${(@k)ALIAS_DIRS}"; do
	if [ -d "$d" ]; then
		hash -d $ALIAS_DIRS[$d]=$d
		_zsh_load_info="$_zsh_load_info\naliased dir $d"
	fi
done
unset d ALIAS_DIRS

export FZF_DEFAULT_OPTS='-e --height=15 --reverse'
export FZF_TMUX=0
if has rg; then
	export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" --glob "!*.pyc"'
	export FZF_CTRL_T_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" --glob "!*.pyc"'
	_zsh_load_info="$_zsh_load_info\nfound rg and set up fzf"
fi

[ -d ~/.config ] && export XDG_CONFIG_HOME=~/.config

has flake8 && alias flake8="flake8 --ignore=E501"
alias md5sum=md5

if has nvim; then
	alias vim=nvim
	export EDITOR=nvim
	export VISUAL=nvim
	export MANPAGER="nvim -c 'set ft=man' -"
else
	export EDITOR=vim
	export VISUAL=vim
fi

autoload colors && colors
REPORTTIME=10
TIMEFMT="$fg[green]%J$reset_color  $fg[blue]%U user $fg[yellow]%S system $fg[magenta]%P cpu $fg[red]%*E total"

for f in $FILES; do
	if [ -f $f ]; then
		_zsh_load_info="$_zsh_load_info\nsourced file $f"
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
bindkey -e "^XG" git-commit-edit
if has exa; then
	alias lg='exa -l --git --color-scale'
	alias ll='exa -l --color-scale'
	alias lt='exa -l -T --git --color-scale'
	alias ls='exa'
	_zsh_load_info="$_zsh_load_info\nfound exa and configured aliases"
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

if [[ -f /usr/local/opt/nvm/nvm.sh ]]; then
	_zsh_load_info="$_zsh_load_info\nset up nvm"
	manpath=$MANPATH
	export NVM_DIR="$HOME/.nvm"
	. "/usr/local/opt/nvm/nvm.sh"
	export MANPATH=$manpath
	unset manpath
fi

# use path of $HOME as proxy for detecting OS X without running uname
if [[ $HOME =~ Users ]]; then
	alias tidy-finder="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user"
fi

# show available tmux sessions
if [[ -z $TMUX ]]; then
	if has tmux; then
		sessions=$( tmux ls 2> /dev/null | awk '! /attached/ { sub(":", "", $1); print $1; }' | xargs echo )
		if [[ ! -z $sessions ]]; then
			echo "==> Available tmux sessions: $sessions; run 't' to attach"
		fi
		unset sessions
	fi
else
	if [[ ! -d $HOME/.tmux/plugins/tmux-sensible ]]; then
		echo '==> tmux plugins not installed?'
	fi
fi

_zcompdump="$HOME/.zcompdump"
if [[ ! -f "$_zcompdump" ]]; then
	# Completion cache is older than 24h, regenerate
	compinit -d $_zcompdump
	_zsh_load_info="$_zsh_load_info\nran compinit (missing)"
elif [[ -n $_zcompdump(#qN.mh+24) ]]; then
	# Completion cache is older than 24h, regenerate
	rm -f $_zcompdump
	compinit -d $_zcompdump
	_zsh_load_info="$_zsh_load_info\nran compinit (too old)"
else
	# Completion cache is newish, load quickly
	compinit -C;
	_zsh_load_info="$_zsh_load_info\nused compinit cache"
fi
unset _zcompdump

# kick off a recompile of .zsh and the compdump file in the background, if needed
( autoload -U zrecompile && zrecompile -p ~/.zshrc -- ~/.zcompdump > /dev/null ) &!
export ZSH_AUTOSUGGEST_USE_ASYNC=1
