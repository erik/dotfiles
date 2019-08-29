# .files

Using GNU stow to manage various configurations.

    stow    PKG  # install PKG
    stow -D PKG  # uninstall PKG

With no additional arguments, `stow` will install configurations to
the parent directory. It's probably a good idea to clone this to a top
level directory in `~`, like `~/dotfiles`.
