# .zshenv is always sourced (even for non-interactive shells).
#
# Set important environment variables and update PATH here.

# Instruct Zsh to look in ~/.config/zsh/ instead of ~/
export ZDOTDIR=${ZDOTDIR:=$HOME/.config/zsh/}

# Zsh has `PATH` (a string) and `path` (an array)
# typeset -U declares them as unique, and removes duplicates.
typeset -U PATH path
path+=("$HOME/bin")

export EDITOR=nvim

# NOTE: (N) is the NULL_GLOB option, makes it silent when there are no
#   matches
for f in "$ZDOTDIR/env/*"(N); do
    source "$f"
done
