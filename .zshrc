# Set the key mapping style to 'emacs' or 'vi'.
zstyle ':prezto:module:editor' key-bindings 'emacs'

# Auto convert .... to ../..
zstyle ':prezto:module:editor' dot-expansion 'yes'

source ~/.zplug/init.zsh

ZSH_LOCAL_PLUGINS="~/.zshnew/local-plugins"

# borrowed from prezto
zplug "$ZSH_LOCAL_PLUGINS/environment", from:local, nice:-10
zplug "$ZSH_LOCAL_PLUGINS/helper", from:local, nice:-9
zplug "$ZSH_LOCAL_PLUGINS/editor", from:local
zplug "$ZSH_LOCAL_PLUGINS/history", from:local
zplug "$ZSH_LOCAL_PLUGINS/directory", from:local
zplug "$ZSH_LOCAL_PLUGINS/spectrum", from:local
zplug "$ZSH_LOCAL_PLUGINS/utility", from:local, nice:5
zplug "$ZSH_LOCAL_PLUGINS/prompt-sorin", from:local, nice:5

zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", nice:10

zplug load --verbose

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

unsetopt MAIL_WARNING
setopt NOTIFY

unsetopt AUTO_CD
setopt TRANSIENT_RPROMPT

zstyle ':prezto:module:editor:info:keymap:primary' format ' %B%F{2}❯%f%b'


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
	/usr/local/etc/profile.d/z.sh
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

export FZF_DEFAULT_OPTS='-e'
export FZF_TMUX=0

[ -d ~/.config ] && export XDG_CONFIG_HOME=~/.config

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

# override from emacs-forword-word for the autosuggest feature
bindkey '^[f' forward-word
