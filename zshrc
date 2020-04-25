autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
zstyle ':vcs_info:*' enable git

# disable if slow, use python
zstyle ':vcs_info:*' check-for-changes false

# Add ! for unstaged changes, on prompt maps to %u
zstyle ':vcs_info:*' unstagedstr '%{%F{red}%B%}!%{%b%f%}'

# Add + for staged changes, on prompt maps to %c
zstyle ':vcs_info:*' stagedstr '%{%F{green}%B%}+%{%b%f%}'

# zstyle ':vcs_info:*' actionformats \
#       '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' actionformats       \
      '%F{5}(%F{2}%b%F{5})%f %m%u%c '
zstyle ':vcs_info:*' formats       \
      '%F{5}(%F{2}%b%F{5})%f %m%u%c '

# zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
export PATH="/usr/local/sbin:$PATH"
PROMPT='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_}%f%# '
