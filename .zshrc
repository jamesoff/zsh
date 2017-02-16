if [ ! -d ~/.zplug ]; then
	echo Installing zplug...
	git clone git@github.com:zplug/zplug.git .zplug
	source ~/.zplug/init.zsh
	echo Installing plugins...
	ZPLUG_INSTALL_NEEDED=1
else
	source ~/.zplug/init.zsh
	ZPLUG_INSTALL_NEEDED=0
fi

zstyle ':prezto:module:editor' key-bindings 'emacs'
zstyle ':prezto:module:editor' dot-expansion 'yes'

# Prepare prompt theme
fpath=(${ZDOTDIR:-$HOME/.zsh}/local-plugins/prompt-sorin $fpath)
autoload -Uz promptinit && promptinit

ZSH_LOCAL_PLUGINS="~/.zsh/local-plugins"

# self-manage
#zplug "zplug/zplug"

# borrowed from prezto
zplug "$ZSH_LOCAL_PLUGINS/environment", from:local
zplug "$ZSH_LOCAL_PLUGINS/helper", from:local
zplug "$ZSH_LOCAL_PLUGINS/editor", from:local
zplug "$ZSH_LOCAL_PLUGINS/history", from:local
zplug "$ZSH_LOCAL_PLUGINS/directory", from:local
zplug "$ZSH_LOCAL_PLUGINS/spectrum", from:local
zplug "$ZSH_LOCAL_PLUGINS/completion", from:local
zplug "$ZSH_LOCAL_PLUGINS/utility", from:local
zplug "$ZSH_LOCAL_PLUGINS/git", from:local
zplug "$ZSH_LOCAL_PLUGINS/osx", from:local, if:"[[ $OSTYPE == *darwin* ]]"
zplug "mafredri/zsh-async"

zplug "$ZSH_LOCAL_PLUGINS/aws", from:local
zplug "supercrabtree/k", use:"*.sh", hook-build:"chmod 755 k.sh"
zplug "rupa/z", use:"z.sh"

zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

if [[ $ZPLUG_INSTALL_NEEDED == 1 ]]; then
	zplug install
fi

zplug load

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

unsetopt MAIL_WARNING
setopt NOTIFY

unsetopt AUTO_CD

# Set up prompt
setopt TRANSIENT_RPROMPT
prompt sorin
zstyle ':prezto:module:editor:info:keymap:primary' format '%B%F{2}%%%f%b'
zstyle ':prezto:module:editor:info:keymap:alternate' format '%B%F{1}$%f%b'

# Thing to add to PATH, if they exist
DIRS=(
	/usr/local/bin
	/usr/X11R6/bin
	~/bin
	~/Library/Python/2.7/bin
	~/.local/bin
	)

# Things to source, if they exist
FILES=(
	/usr/local/share/zsh/site-functions/_aws
	/Users/james/.travis/travis.sh
	~/.iterm2_shell_integration.zsh
	~/.fzf.zsh
	)

# Dirs to alias, if they exist
typeset -A ALIAS_DIRS
ALIAS_DIRS=(
	/Users/jseward61/src/chef_repo/cookbooks chef
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

export FZF_DEFAULT_OPTS='-e'
export FZF_TMUX=0

[ -d ~/.config ] && export XDG_CONFIG_HOME=~/.config

# Use ports/brew gcc if installed
if [ -x /usr/local/bin/gcc ]; then
	export CC=/usr/local/bin/gcc
	export CXX=/usr/local/bin/gcc
fi

if [ -d /Users/jseward61 ]; then
	export KRB5CCNAME=/tmp/jseward61_krb5cache
	alias kinit="kinit -c $KRB5CCNAME jseward@AOL.COM"
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
	dir=$( d | fzf --header="Recent directories" --inline-info | awk '{print $1}' )
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

# use path of $HOME as proxy for detecting OS X without running uname
if [[ $HOME =~ Users ]]; then
	alias tidy-finder="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user"
fi

if [[ ! -z $TMUX ]]; then
	tmux rename-window 
fi

