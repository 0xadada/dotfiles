# dotfiles

![Screencast of the shell prompt](https://media.giphy.com/media/UsT5IGZ5dSRlL0nxjQ/giphy.gif)

## Installation

```bash
mkdir -p dotfiles && \
  curl -#L https://github.com/0xadada/dotfiles/tarball/master | \
  tar -xzv -C dotfiles --strip-components=1
cd dotfiles
./bootstrap.sh
```

Bootstrap will install the dotfiles, and install core utilities:

* Bash shell and git, latest versions
* Homebrew, [casks and its packages](https://github.com/0xadada/dotfiles/blob/master/Brewfile)
* `asdf` (with latest Stable Elixir, Erlang, NodeJS, Python 3, Ruby)

To update, `cd` into `dotfiles` and then:

```bash
./bootstrap.sh
```

## macOS hacker defaults

When setting up a new Macbook, you may want to set some hacker macOS defaults:

```bash
./.macos
```

## Add custom commands without creating a new fork

If `~/.bash_custom` exists, it will be sourced along with the other files. You
can use this to add a few custom commands without the need to fork this entire
repository, or to add commands you don’t want to commit to a public repository.

## Thanks to…

* [Mathias Bynens](http://twitter.com/mathias) and his [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
* [ptb](https://github.com/ptb) and his [Mac Setup](https://github.com/ptb/mac-setup) repository
* [drduh](https://github.com/drduh/macOS-Security-and-Privacy-Guide) and his [macOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)
* anyone who [contributed a patch](https://github.com/mathiasbynens/dotfiles/contributors) or [made a helpful suggestion](https://github.com/mathiasbynens/dotfiles/issues)
