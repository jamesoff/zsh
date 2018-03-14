# My zsh setup

This is mostly in git for my benefit, but you're welcome to use it.

## Features

Non-exhaustive list:

* Minimal prompt; everything on one line unless terminal is narrow, then prompt line moves under CWD
* Long paths in the prompt fade in to draw the eye
* Username and hostname only appear on remote sessions; hostname is coloured by host automatically
* Information about shell state appears on RHS, with slow items populated async to avoid slowing down prompt appearance
    - last command exit status
    - git branch and repo status
    - AWS profile and region in environment
    - Python virtualenv
    - if valid Kerberos ticket is held*
    - if VPN is connected*
* Sets terminal title to process/cwd (via plugin)
* Lots of fzf
* Lots of completions (via plugin)
* Syntax highlighting at prompt (via plugin)
* Sensible settings (IMO ;)
* Fast startup (makes use of recompilation and caching)
* Shows unattached tmux sessions at login, as I use tmux for everything
* Show `time` output for commands which took >10s to run

(* these items will need you to hack up some stuff to work for your particular set up)

You will need (for best results):

* zsh, probably a recent one like >= 5.2 or 5.3
* a modern terminal which can do things like 256 colours (or true colours)
* one of the [Nerd fonts](https://github.com/ryanoasis/nerd-fonts) as this uses glyphs from that
* zplugin, which installs and manages some plugins. This should work without though.

You probably want:

* [fzf](https://github.com/junegunn/fzf)
* [rg](https://github.com/BurntSushi/ripgrep) (preferred) or [the silver searcher](https://github.com/ggreer/the_silver_searcher)
* [exa](https://github.com/ogham/exa)
* [fd](https://github.com/sharkdp/fd)

On macOS you can install all of those with homebrew.

## Installing

* clone this repo to `~/.zsh`: `git clone https://github.com/jamesoff/zsh.git ~/.zsh`
* link files: `for i in .zshrc .zprofile .zshenv; do ln -s "~/$i" "~/.zsh/$i"; done`
* install zplugin: `mkdir -p ~/.zplugin && git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin`
* when you run zsh for the first time, zplugin will download and install the plugins required

## Using

This is a non-exhaustive list of things you can use/do with this config

* Hit Ctrl-T for fzf filename insertion
* Hit Ctrl-R for fzf history search
* Hit Alt-D for fzf list of recent directories (in session)
* Type `ecd` for fzf list of directories you use a bunch (takes filter param)
* Type `gita` for fzf `git add`; use filtering and arrow keys to select files, hit Tab to mark file for git staging; hit Enter to exit and stage
* Type `lg` for exa's git list mode; other `ls` variants are aliased to `exa` too
* Hit ^X^G while composing a `git commit -m ...` line to switch to editing the commit message in vim (WIP)
* Type `run-docker ID` to get a bash shell in running container ID
* Type `tidy-docker` to purge exited containers and untagged images

## See also

You might like my [tmux config](https://jamesoff.net/2017/08/26/tmux-configuration.html) and [vim config](https://bitbucket.org/jamesoff/vim/src) to go with this.
