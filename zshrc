autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

autoload -U add-zsh-hook

# executed whenever current working directory is changed
add-zsh-hook chpwd chpwd_update_git_vars

# executed before the next prompt is displayed
add-zsh-hook precmd precmd_update_git_vars

# executed before a command is executed
add-zsh-hook preexec preexec_update_git_vars

function chpwd_update_git_vars() {
  update_current_git_vars
}

function preexec_update_git_vars() {
  case "$2" in
    git*)
      __EXECUTED_GIT_COMMAND=1
      ;;
  esac
}
function precmd_update_git_vars() {
  if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
    update_current_git_vars
    unset __EXECUTED_GIT_COMMAND
  fi
}

function update_current_git_vars() {
  unset __CURRENT_GIT_STATUS

  local gitstatus="$HOME/.gitstatus.py"
  _GIT_STATUS=$(python ${gitstatus} 2>/dev/null)
  __CURRENT_GIT_STATUS=("${(@s: :)_GIT_STATUS}")
  GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
  GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
  GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
  GIT_STAGED=$__CURRENT_GIT_STATUS[4]
  GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
  GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
  GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
}

# Adapted from https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git-prompt/git-prompt.plugin.zsh
git_super_status() {
  precmd_update_git_vars
  if [ -n "$__CURRENT_GIT_STATUS" ]; then

    STATUS="%F{white}(%F{blue}$GIT_BRANCH"

    if [ "$GIT_BEHIND" -ne "0" ]; then
      STATUS="$STATUS%F{white}%{↓%G%}$GIT_BEHIND"
    fi

    if [ "$GIT_AHEAD" -ne "0" ]; then
      STATUS="$STATUS%F{white}%{↑%G%}$GIT_AHEAD"
    fi

    STATUS="$STATUS%F{white}|"

    if [ "$GIT_STAGED" -ne "0" ]; then
      STATUS="$STATUS%F{green}%{●%G%}$GIT_STAGED"
    fi

    if [ "$GIT_CONFLICTS" -ne "0" ]; then
      STATUS="$STATUS%F{red}%{✖%G%}$GIT_CONFLICTS"
    fi

    if [ "$GIT_CHANGED" -ne "0" ]; then
      STATUS="$STATUS%F{red}%{✚%G%}$GIT_CHANGED"
    fi

    if [ "$GIT_UNTRACKED" -ne "0" ]; then
      STATUS="$STATUS%F{red}%{…%G%}"
    fi

    if [ "$GIT_CHANGED" -eq "0" ] && [ "$GIT_CONFLICTS" -eq "0" ] && [ "$GIT_STAGED" -eq "0" ] && [ "$GIT_UNTRACKED" -eq "0" ]; then
      STATUS="$STATUS%F{white}%{✔%G%}"
    fi

    STATUS="$STATUS%F{white})%f"
    echo "$STATUS"
  fi
}

# enable git
zstyle ':vcs_info:*' enable git

# Add ! for unstaged changes, on prompt maps to %u
# zstyle ':vcs_info:*' unstagedstr '%{%F{red}%B%}!%{%b%f%}'

# Add + for staged changes, on prompt maps to %c
# zstyle ':vcs_info:*' stagedstr '%{%F{green}%B%}+%{%b%f%}'

# zstyle ':vcs_info:*' actionformats '%F{5}(%F{2}%b%F{5})%f %m%u%c '
# zstyle ':vcs_info:*' formats '%F{5}(%F{2}%b%F{5})%f %m%u%c '

# zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
export PATH="/usr/local/sbin:$PATH"
PROMPT='%F{5}[%F{2}%n%F{5}] %F{3}%3~ $(git_super_status)%f%# '

export CLICOLOR=1

# For rbenv
export PATH="/usr/local/opt/ruby/bin:$PATH"
eval "$(rbenv init -)"
