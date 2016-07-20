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

# borrowed from prezto
zplug "$ZSH_LOCAL_PLUGINS/environment", from:local, nice:-10
zplug "$ZSH_LOCAL_PLUGINS/helper", from:local, nice:-9
zplug "$ZSH_LOCAL_PLUGINS/editor", from:local
zplug "$ZSH_LOCAL_PLUGINS/history", from:local
zplug "$ZSH_LOCAL_PLUGINS/directory", from:local
zplug "$ZSH_LOCAL_PLUGINS/spectrum", from:local
zplug "$ZSH_LOCAL_PLUGINS/completion", from:local
zplug "$ZSH_LOCAL_PLUGINS/utility", from:local, nice:5
zplug "$ZSH_LOCAL_PLUGINS/git", from:local
zplug "mafredri/zsh-async"

zplug "$ZSH_LOCAL_PLUGINS/aws", from:local
zplug "supercrabtree/k", use:"*.sh", hook-build:"chmod 755 k.sh"
zplug "rupa/z", use:"z.sh"

zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", nice:10

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
	~/.nvim/bundle/neoman.vim/scripts/neovim.zsh
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

# Make clean tarballs on OS X without extended attrs
export COPYFILE_DISABLE=true

export EDITOR=nvim
export VISUAL=nvim
export CLICOLOR=true

export FZF_DEFAULT_OPTS='-e'
export FZF_TMUX=0

[ -d ~/.config ] && export XDG_CONFIG_HOME=~/.config

# Use ports/brew gcc if installed
if [ -x /usr/local/bin/gcc ]; then
	export CC=/usr/local/bin/gcc
	export CXX=/usr/local/bin/gcc
fi


alias flake8="flake8 --ignore=E501"
alias md5sum=md5
hash nvim &> /dev/null && alias vim=nvim
hash pygmentize &> /dev/null && alias cat="pygmentize -g"

REPORTTIME=10

function tidy_nagios() {
	python ~/src/puppet/modules/nagios/tidy_nagios.py "$1" > "${1}_tmp" && mv "$1_tmp" "$1"
}


function watch_elb () {
	watch -n 10 "aws elb describe-instance-health --load-balancer-name "$1" | jq '.InstanceStates[].State' | sort | uniq -c"
}

function agvim () {
	CHOICE=$(ag --color $* | fzf -0 -1 --ansi)
	if [ ! -z "$CHOICE" ]; then
		# Open vim at the selected file and line, but also run the Ag scan
		# the ! on Ag! stops Ag jumping to the first match, and the wincmd gives the editor window focus
		nvim $( echo "$CHOICE" | awk 'BEGIN { FS=":" } { printf "+%d %s\n", $2, $1 } ') +"Ag! '$*'" "+wincmd k"
	fi
}

function try_ssh () {
	SUCCESS=0
	while [ $SUCCESS -eq 0 ]; do
		ssh -o "ConnectTimeout 30" $*
		RESULT=$?
		if [ $RESULT -ne 255 ]; then
			SUCCESS=1
		else
			echo "--> SSH return code was $RESULT"
			print "Waiting to retry ssh..."
			sleep 10
			echo "--> Retrying..."
		fi
	done
}


function vpn () {
	if $( pgrep vpnc > /dev/null ); then
		echo "--> Disconnecting VPN"
		sudo /usr/local/sbin/vpnc-disconnect
	else
		echo "--> Connecting VPN"
		sudo /usr/local/sbin/vpnc
	fi
}

function brew-upgrade () {
	brew update
	brew outdated | fzf -m -n 1 --tac --header='Select formulae to upgrade with tab' | xargs brew upgrade
}

for f in $FILES; do
	if [ -f $f ]; then
		source $f
	fi
done

if [[ "$( uname )" == "Darwin" ]]; then
	function fix-ssh-agent () {
		listener=$( \find /private/tmp/com.apple.launchd.* -name Listeners -type s ) && export SSH_AUTH_SOCK="$listener"
	}
fi

# override from emacs-forword-word for the autosuggest feature
bindkey '^[f' forward-word

