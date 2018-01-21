fpath=( ~/.zsh/local-plugins/osx/autoload $fpath )

autoload brew-upgrade fix-ssh-agent

# Use ports/brew gcc if installed
if [ -x /usr/local/bin/gcc ]; then
	export CC=/usr/local/bin/gcc
	export CXX=/usr/local/bin/gcc
fi
