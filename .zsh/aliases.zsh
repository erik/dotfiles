alias ..='cd ..'

# ls
alias ls="ls --color=auto"
alias l="ls -lAh"
alias ll="ls -l"
alias la='ls -A'

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# git
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias changelog='git log `git log -1 --format=%H -- CHANGELOG*`..; cat CHANGELOG*'

# irb
alias irb='irb --simple-prompt'

# apt
alias get='sudo apt-get install'
alias apt-search='apt-cache search'
