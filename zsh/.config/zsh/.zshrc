# .zshrc is sourced for interactive shells.

# For profiling startup:
#
# zmodload zsh/zprof
#
# Call zprof at the end

#
# Miscellaneous Options
#
setopt autocd

#
# Completion
#
autoload -Uz +X compinit && compinit -C
autoload -U +X bashcompinit && bashcompinit

# What does this mean??
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

setopt COMPLETE_ALIASES

#
# Command history
#

setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

export HISTTIMEFORMAT="[%F %T] "
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export HISTFILE=~/.zsh_history

#
# Key Bindings
#

# Use Emacs movement. Apply this first since it obliterates our key map.
bindkey -e

# Create a TERM/OS specific keymap if it doesn't exist. Note the -*. For some
# reason, zkbd generates ...-darwin.19.0, but want ...-darwin-19.3.0.
#
# idk. $TERM-$VENDOR is probably unique enough for now.
autoload zkbd
[ ! -f ~/.config/zsh/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-*} ] && zkbd
source ~/.config/zsh/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-*}

# Make sure TERM-specific keys are working
bindkey "${key[Backspace]}" backward-delete-char
bindkey "${key[Delete]}" delete-char

bindkey -r "^[/"
bindkey "^[/" undo

# C-x C-e is really handy for long commands
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

#
# Custom autoloads
#
fpath+=("$ZDOTDIR/functions")
autoload -Uz defer-source
autoload -Uz git-current-branch
autoload -Uz kubernetes-ssh
autoload -Uz vv
autoload -Uz uex

#
# Aliases
#
alias n='nvim'
alias b='bat'
alias ..='cd ..'
alias ls='ls -G'
alias la='ls -AG'
alias ll='ls -lGh'
alias l='ls -alhG'
alias gb="git branch --format='%(refname)' | sed 's;refs/heads/;;g' | fzf --preview 'git log --color=always {}' | xargs git checkout"
alias git-prune-branches='git branch | grep -v master | fzf --multi --preview "git log --color=always {}" | xargs git branch -D'

#
# Prompt
#
setopt PROMPT_SUBST
export PROMPT="%F{magenta}%B%D{%H:%M}%b%f %2/ %B%F{magenta}\$(git-current-branch)%b%f %B‣%b "

#
# Deferred sourcing of files that modify the shell environment for
# quicker startup.
#

defer-source \
   "${NVM_DIR:-$HOME/.nvm}/nvm.sh" \
   nvm npm node npx

defer-source \
    /usr/local/etc/profile.d/autojump.sh \
    j jo jco

defer-source \
    /usr/local/opt/asdf/asdf.sh \
    asdf
