# get rid of fzf-tmux
export ENHANCD_FILTER=fzf
export ENHANCD_COMMAND=ecd
export LANG=en_GB.UTF-8

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
for plugin in environment helper editor history directory spectrum completion utility git aws; do
	source "$ZSH_LOCAL_PLUGINS/$plugin/init.zsh"
done
unset ZSH_LOCAL_PLUGINS

if [[ $_zplugin_available == 1 ]]; then
	zplugin light "mafredri/zsh-async"
	zplugin light "jreese/zsh-titles"
	zplugin light "b4b4r07/enhancd"
	zplugin light "zsh-users/zsh-completions"
	zplugin light "zdharma/fast-syntax-highlighting"
fi

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

unsetopt MAIL_WARNING
setopt NOTIFY

unsetopt AUTO_CD

# Set up prompt
setopt TRANSIENT_RPROMPT
prompt sorin
zstyle ':prezto:module:editor:info:keymap:primary' format '%B%F{31}%%%f%b'
zstyle ':prezto:module:editor:info:keymap:alternate' format '%B%F{1}$%f%b'

# Thing to add to PATH, if they exist
DIRS=(
	/usr/local/bin
	/usr/X11R6/bin
	~/bin
	~/Library/Python/2.7/bin
	~/.local/bin
	~/.cargo/bin
	)

# Things to source, if they exist
FILES=(
	/Users/james/.travis/travis.sh
	~/.iterm2_shell_integration.zsh
	~/.fzf.zsh
	~/.config/homebrew-token
	)

# Dirs to alias, if they exist
typeset -A ALIAS_DIRS
ALIAS_DIRS=(
	/Users/jseward61/src/chef_repo/cookbooks chef
	~/src src
	)

export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
for d in $DIRS; do
	if [ -d $d ]; then
		export PATH=$PATH:$d
	fi
done
NEWPATH=$(echo $PATH | awk -F: '{for (i=1;i<=NF;i++) { if ( !x[$i]++ ) printf("%s:",$i); }}')
PATH=${NEWPATH:0:-1}
unset DIRS NEWPATH

for d in "${(@k)ALIAS_DIRS}"; do
	if [ -d "$d" ]; then
		hash -d $ALIAS_DIRS[$d]=$d
	fi
done
unset d ALIAS_DIRS

# Make clean tarballs on OS X without extended attrs
export COPYFILE_DISABLE=true

export CLICOLOR=true

export FZF_DEFAULT_OPTS='-e --height=15 --reverse'
export FZF_TMUX=0
has rg && export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" --glob "!*.pyc"'
has rg && export FZF_CTRL_T_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" --glob "!*.pyc"'

export VIRTUAL_ENV_DISABLE_PROMPT=1

[ -d ~/.config ] && export XDG_CONFIG_HOME=~/.config

# Use ports/brew gcc if installed
if [ -x /usr/local/bin/gcc ]; then
	export CC=/usr/local/bin/gcc
	export CXX=/usr/local/bin/gcc
fi

if [ -d /Users/jseward61 ]; then
	export KRB5CCNAME=/tmp/jseward61_krb5cache
	export KERB_ID=jseward
	alias kinit="kinit -c $KRB5CCNAME $KERB_ID@AOL.COM"
	export VAULT_ADDR=https://oe-vault.us-east-1.aolp-prd.aolcloud.net:8200
fi

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

REPORTTIME=10

for f in $FILES; do
	if [ -f $f ]; then
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
	alias lg='exa -l --git'
else
	lg-missing() { echo 'exa is not installed :(' }
	alias lg=lg-missing
fi

if has yinit; then
	alias ysock="export SSH_AUTH_SOCK=$HOME/.yubiagent/sock"
	yinit() {
		if ! [[ $SSH_AUTH_SOCK =~ yubiagent ]]; then
			echo 'Switching to yubiagent SSH socket'
			export SSH_AUTH_SOCK=$HOME/.yubiagent/sock
		fi
		command yinit $@
	}
fi

# use path of $HOME as proxy for detecting OS X without running uname
if [[ $HOME =~ Users ]]; then
	alias tidy-finder="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user"
fi

# show available tmux sessions
if [[ -z $TMUX ]]; then
	sessions=$( tmux ls 2> /dev/null | awk '! /attached/ { sub(":", "", $1); print $1; }' | xargs echo )
	if [[ ! -z $sessions ]]; then
		echo "==> Available tmux sessions: $sessions"
	fi
	unset sessions
fi

if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
	# Completion cache is older than 24h, regenerate
	compinit;
else
	# Completion cache is newish, load quickly
	compinit -C;
fi;

# kick off a recompile of .zsh and the compdump file in the background, if needed
( autoload -U zrecompile && zrecompile -p ~/.zshrc -- ~/.zcompdump > /dev/null ) &!
