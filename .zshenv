# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Thing to add to PATH, if they exist
DIRS=(
	/usr/local/bin
	/usr/X11R6/bin
	~/bin
	~/Library/Python/2.7/bin
	~/Library/Python/3.7/bin
	~/Library/Python/3.6/bin
	~/.local/bin
	~/.cargo/bin
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
