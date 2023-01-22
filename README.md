# My zsh setup

This is mostly in git for my benefit, but you're welcome to use it.

## Features

Non-exhaustive list:

* Uses [Starship](https://starship.rs) for prompt; customise to your taste
* Lots of fzf
* Lots of completions (via plugin)
* Syntax highlighting at prompt (via plugin)
* Sensible settings (IMO ;)
* Fast startup (makes use of recompilation and caching)
* Shows unattached tmux sessions at login, as I use tmux for everything
* Show `time` output for commands which took >10s to run
* Stores a log of what was enabled/configured during startup
* Sets up some hashed dir names (if the targets exist)
    * `~src` is `~/src`
    * `~tmp` is `~/tmp`
    * `~icloud` is iCloud Drive
* Strongly prefers neovim if it's available (else vim); sets up nvim as man page viewer
* Sets up a bunch of `ls`-type aliases to `exa` if installed
    * `ll`, `la` for long and "all" lists
    * `lg` for exa's "git" display
* Lazy-loads nvm, because it takes a million years to run the first time
* Lazy-compile completions (can cause harmless errors on shell launches after an upgrade)

## Aliases/commands

Again, non-exhaustive.

* `t` will launch or attach a tmux session. The one used depends on the terminal size (`local` or `fullscreen`). I always run in a tmux session, so I just run `t` as the first thing in a window, generally.
* `rv` uses `rg` to search files, then uses `fzf` to let you pick one to open in vim
* `fv` likewise uses `fd` to search matching filenames, and uses `fzf` to pick
* `venv` will activate a virtualenv in `./.venv` if it exists, else offer to create it and install requirements
* `gita` uses `fzf` to give you an interactive file-picker for committing to git
* `try` followed by a command will run that command with exponential backoff until it succeeds; great for `try ssh ...` after rebooting a host. Also good with history expansion: `try !!`
* `aws-profile` switches profiles from your awscli config with tab-completion; `aws-region` for regions (I think the list is probably out of date ;)
* There's a bunch of other aws functions in there; check out the `local-plugins/aws` stuff if they're of interest
* If neovim is installed, then `vim` and `vi` are aliased to it; `$EDITOR` and `$VISUAL` are set too.
* `run-docker IMAGE` runs that image and gives you a bash shell
* `tidy-docker` gets rid of cruft
* `cat` is aliases to `bat` if it's installed
* `show-certificate` dumps a TLS cert file with openssl

## Keystrokes

* <key>Ctrl-r</key> for fzf-powered shell history
* <key>Ctrl-t</key> for fzf-powered filename picker
* <key>Alt-c</key> for fzf-powered directory picker
* <key>Alt-d</key> for fzf-powered directory history
* <key>Ctrl-x e</key> to edit current command line in vim
* <key>Alt-f</key> to accept forward a word from the autosuggest display; right-arrow to accept the whole line

# Setting up

You will need (for best results):

* zsh, probably a recent one like >= 5.2 or 5.3
* a modern terminal which can do things like 256 colours (or true colours)
* one of the [Nerd fonts](https://github.com/ryanoasis/nerd-fonts) as this uses glyphs from that
* zplugin, which installs and manages some plugins. This should work without though, but not as well

You probably want:

* [fzf](https://github.com/junegunn/fzf)
* [rg](https://github.com/BurntSushi/ripgrep) (preferred)
* [exa](https://github.com/ogham/exa)
* [fd](https://github.com/sharkdp/fd)
* [bat](https://github.com/sharkdp/bat)
* [starship](https://starship.rs)
* [zplug](https://github.com/zplug/zplug)

On macOS you can install all of those with homebrew.

* clone this repo to `~/.zsh`: `git clone https://github.com/jamesoff/zsh.git ~/.zsh`
* link files: `for i in .zshrc .zprofile .zshenv; do ln -s "$HOME/.zsh/$i" "$HOME/$i"; done`
* when you run zsh for the first time, zplug will download and install the plugins required

## See also

You might like my [tmux config](https://jamesoff.net/2017/08/26/tmux-configuration.html) and [vim config](https://bitbucket.org/jamesoff/vim/src) to go with this.
